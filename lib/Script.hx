import hscript.Expr;

class Script {

	var game : Game;
	var file : String;
	var i : ScriptInterp;
	var api : ScriptGlobals;
	var funNames : Map<String,Bool>;
	var currentLoop : hscript.Expr;
	var currentBreak : hscript.Expr;
	var argNames : Array<String> = [];
	var currentFun : String;
	var uid = 0;

	public function new(file) {
		game = Game.inst;
		funNames = new Map();
		this.file = file;
	}

	public function load(content) {
		var e : hscript.Expr;
		var p = new hscript.Parser();
		try {
			e = content == null ? EBlock([]) : p.parseString(content);
		} catch( e : hscript.Expr.Error ) {
			throw e+" line " + p.line+" in "+file;
		}

		e = buildAsync(e);

		i = new ScriptInterp();

		// add API
		api = new ScriptGlobals(this);
		var c = Type.getClass(api);
		for( f in Type.getInstanceFields(c) ) {
			var fv = Reflect.field(api, f);
			if( !Reflect.isFunction(fv) ) continue;
			if( f.charCodeAt(0) == "_".code && f != "__new__" ) f = f.substr(1);
			i.variables.set(f, fv);
			if( f.substr(0, 2) != "a_" && !i.variables.exists("a_"+f) )
				i.variables.set("a_" + f, Reflect.makeVarArgs(function(args) {
					var onEnd = args.shift();
					onEnd(Reflect.callMethod(api, fv, args));
				}));
		}
		api.initVariables(i.variables);
		i.execute(e);
	}

	public function eval( code : String, async = true ) : Dynamic {
		var e = new hscript.Parser().parseString(code);
		if( async ) {
			e = toCps(e, EFunction([{name:"x"}],EReturn(EIdent("x"))), EReturn());
		}
		return i.execute(e);
	}

	public function hasMethod( name : String ) {
		var v = i.variables.get("a_" + name);
		return v != null && Reflect.isFunction(v);
	}

	public function callVal( value : Dynamic, args : Array<Dynamic>, onEnd : Void -> Void, ?vthis : {} ) {
		var oldThis = i.variables.get("this");
		if( vthis != null )
			i.variables.set("this", vthis);
		args.unshift(function(_) {
			onEnd();
		});
		Reflect.callMethod(null, value, args);
		i.variables.set("this", oldThis);
	}

	public function call( id, args : Array<Dynamic>, onEnd : Void -> Void, ?vthis : Dynamic ) {
		var v = i.variables.get("a_" + id);
		if( v == null ) {
			trace("Missing function " + id + "()");
			onEnd();
			return;
		}
		args.unshift(function(_) {
			onEnd();
		});
		i.variables.set("this", vthis);
		Reflect.callMethod(null, v, args);
	}

	function buildAsync( e : hscript.Expr ) {
		switch( e ) {
		case EFunction(args, body, name, t) if( name == null || !StringTools.startsWith(name,"init") ):
			if( name != null ) funNames.set(name, true);
			for( a in args )
				argNames.push(a.name);
			args.unshift( { name : "_onEnd", t : null } );
			var rest = EIdent("_onEnd");
			var oldFun = currentFun;
			currentFun = name;
			var body = toCps(body, rest, rest);

			//body = EBlock([ECall(EIdent("_enter"), [EConst(CString(name == null ? "<local>" : name))]), body, ECall(EIdent("_leave"), [])]);

			var f = EFunction(args, body, "a_" + name, t);

			for( a in 0...args.length-1 )
				argNames.pop();
			//throw(hscript.Printer.toString(f));
			return f;
		case EBlock(el):
			for( e in el )
				switch( e ) {
				case EFunction(_, _, name, _) if( name != null && !StringTools.startsWith(name,"init") ):
					funNames.set(name, true);
				default:
				}
			return EBlock([for(e in el) buildAsync(e)]);
		case ENew(cl, args):
			args.unshift(EConst(CString(cl)));
			return ECall(EIdent("__new__"), args);
		case EIdent(i) if( funNames.exists(i) ):
			return EIdent("a_" + i);
		default:
			return hscript.Tools.map(e, buildAsync);
		}
		return e;
	}

	function ignore(e) {
		return EFunction([{ name : "_", t : null }], EBlock([e]));
	}

	function retNull(e) {
		return ECall(e, [EIdent("null")]);
	}

	function makeCall( ecall, args : Array<hscript.Expr>, rest : hscript.Expr, exit, sync = false ) {
		var names = [for( i in 0...args.length ) "_a"+uid++];
		var rargs = [for( i in 0...args.length ) EIdent(names[i])];
		if( !sync )
			rargs.unshift(rest);
		var rest = sync ? ECall(rest,[ECall(ecall, rargs)]) : ECall(ecall, rargs);
		var i = args.length - 1;
		while( i >= 0 ) {
			rest = toCps(args[i], EFunction([ { name : names[i], t : null } ], rest), exit);
			i--;
		}
		return rest;
	}

	function isSync( e : hscript.Expr ) {
		switch( e ) {
		case EBlock(el), EArrayDecl(el):
			for( e in el )
				if( !isSync(e) )
					return false;
			return true;
		case EParent(e):
			return isSync(e);
		case EUnop(_, _, e):
			return isSync(e);
		case EBinop(_, e1, e2):
			return isSync(e1) && isSync(e2);
		case EIf(econd, e1, e2), ETernary(econd, e1, e2):
			return isSync(econd) && isSync(e1) && (e2 == null || isSync(e2));
		case EConst(_):
			return true;
		case EIdent(i):
			return !funNames.exists(i);
		case ECall(_):
			return false;
		case EField(e, _):
			return isSync(e);
		case EObject(fl):
			for( f in fl )
				if( !isSync(f.e) )
					return false;
			return true;
		default:
			return false;
		}
		return true;
	}

	function toCps( e : hscript.Expr, rest : hscript.Expr, exit : hscript.Expr ) {
		if( isSync(e) )
			return ECall(rest, [e]);
		switch( e ) {
		case EBlock(el):
			while( el.length > 0 ) {
				var e = toCps(el.pop(), rest, exit);
				rest = ignore(e);
			}
			return retNull(rest);
		case EParent(e):
			return EParent(toCps(e, rest, exit));
		case ECall(EIdent(name = ("split" | "async")), args):
			var args = [for( a in args ) EFunction([ { name : "_rest", t : null } ], toCps(EBlock([a]), EIdent("_rest"), exit))];
			return ECall(EIdent(name), [rest, EArrayDecl(args)]);
		case ECall(EIdent(i), args):
			var isSync = StringTools.startsWith(i, "init") && argNames.indexOf(i) < 0;
			return makeCall( EIdent( argNames.indexOf(i) < 0 && !isSync ? "a_" + i : i) , args, rest, exit, isSync );
		case ECall(EField(e, f), args):
			return makeCall(EField(e,"a_"+f), args, rest, exit);
		case EFor(v, eit, e):
			var id = ++uid;
			var it = EIdent("_i" + id);
			var oldLoop = currentLoop, oldBreak = currentBreak;
			var loop = EIdent("_loop" + id);
			currentLoop = loop;
			currentBreak = EBlock([ECall(rest, [EIdent("null")]), EReturn()]);
			var e = EBlock([
				EVar("_i" + id, ECall(EIdent("makeIterator"),[eit])),
				EFunction([{ name : "_", t : null }], EBlock([
					EIf(EUnop("!", true, ECall(EField(it, "hasNext"), [])), currentBreak),
					EVar(v, ECall(EField(it, "next"), [])),
					toCps(e, loop, exit),
				]),"_loop" + id),
				ECall(loop, [EIdent("null")]),
			]);
			currentLoop = oldLoop;
			currentBreak = oldBreak;
			return e;
		case EUnop(op = "!", prefix, e):
			return toCps(e, EFunction([ { name:"_r", t:null } ], ECall(rest, [EUnop(op, prefix, EIdent("_r"))])), exit);
		case EBinop(op, e1, e2):
			switch( op ) {
			case "=", "+=", "-=", "/=", "*=", "%=", "&=", "|=", "^=":
				switch( e1 ) {
				case EIdent(_):
					var id = "_r" + uid++;
					return toCps(e2, EFunction([ { name:id, t:null } ], ECall(rest, [EBinop(op, e1, EIdent(id))])), exit);
				case EField(e1, f):
					var id1 = "_r" + uid++;
					var id2 = "_r" + uid++;
					return toCps(e1, EFunction([ { name:id1, t:null } ], toCps(e2, EFunction([ { name : id2, t : null } ], ECall(rest, [EBinop(op, EField(EIdent(id1),f), EIdent(id2))])), exit)), exit);
				case EArray(earr, eindex):
					var idArr = "_r" + uid++;
					var idIndex = "_r" + uid++;
					var idVal = "_r" + uid++;
					return toCps(earr,
						EFunction([ { name:idArr, t:null } ], toCps(eindex,
							EFunction([ { name : idIndex, t : null } ], toCps(e2,
								EFunction([ { name : idVal, t : null } ],
									ECall(rest, [EBinop(op, EArray(EIdent(idArr), EIdent(idIndex)), EIdent(idVal))])
								), exit)
							), exit)
						),exit);
				default:
					throw "assert " + e1;
				}
			case "||":
				var id1 = "_r" + uid++;
				var id2 = "_r" + uid++;
				return toCps(e1, EFunction([ { name:id1, t:null } ], EIf(EBinop("==", EIdent(id1), EIdent("true")),ECall(rest,[EIdent("true")]),toCps(e2, rest, exit))), exit);
			case "&&":
				var id1 = "_r" + uid++;
				var id2 = "_r" + uid++;
				return toCps(e1, EFunction([ { name:id1, t:null } ], EIf(EBinop("!=", EIdent(id1), EIdent("true")),ECall(rest,[EIdent("false")]),toCps(e2, rest, exit))), exit);
			default:
				var id1 = "_r" + uid++;
				var id2 = "_r" + uid++;
				return toCps(e1, EFunction([ { name:id1, t:null } ], toCps(e2, EFunction([ { name : id2, t : null } ], ECall(rest, [EBinop(op, EIdent(id1), EIdent(id2))])), exit)), exit);
			}
		case EIf(cond, e1, e2), ETernary(cond, e1, e2):
			return toCps(cond, EFunction([ { name : "_c", t : null } ], EIf(EIdent("_c"), toCps(e1, rest, exit), e2 == null ? retNull(rest) : toCps(e2, rest, exit))), exit);
		case EWhile(cond, e):
			var id = ++uid;
			var loop = EIdent("_loop" + id);
			var oldLoop = currentLoop, oldBreak = currentBreak;
			currentLoop = loop;
			currentBreak = EBlock([ECall(rest, [EIdent("null")]), EReturn()]);
			var ewhile = EBlock([
				EFunction([{ name : "_r", t : null }],
					toCps(cond, EFunction([ { name : "_c", t : null } ], EIf(EIdent("_c"), toCps(e, loop, exit), ECall(rest,[EIdent("null")]))), exit)
				, "_loop"+id),
				ECall(loop, [EIdent("null")]),
			]);
			currentLoop = oldLoop;
			currentBreak = oldBreak;
			return ewhile;
		case EReturn(e):
			return e == null ? ECall(exit, [EIdent("null")]) : toCps(e, exit, exit);
		case EObject(fields):
			var id = "_o" + uid++;
			var rest = ECall(rest, [EIdent(id)]);
			fields.reverse();
			for( f in fields )
				rest = toCps(f.e, EFunction([ { name : "_r", t : null } ], EBlock([
					EBinop("=", EField(EIdent(id), f.name), EIdent("_r")),
					rest,
				])),exit);
			return EBlock([
				EVar(id, EObject([])),
				rest,
			]);
		case EArrayDecl(el):
			var id = "_a" + uid++;
			var rest = ECall(rest, [EIdent(id)]);
			var i = el.length - 1;
			while( i >= 0 ) {
				rest = toCps(el[i], EFunction([ { name : "_r", t : null } ], EBlock([
					EBinop("=", EArray(EIdent(id), EConst(CInt(i))), EIdent("_r")),
					rest,
				])), exit);
				i--;
			}
			return EBlock([
				EVar(id, EArrayDecl([])),
				rest,
			]);
		case EArray(e, eindex):
			var id1 = "_r" + uid++;
			var id2 = "_r" + uid++;
			return toCps(e, EFunction([ { name:id1, t:null } ], toCps(eindex, EFunction([ { name : id2, t : null } ], ECall(rest, [EArray(EIdent(id1), EIdent(id2))])), exit)), exit);
		case EVar(v, t, ev):
			if( ev == null )
				return EBlock([e, ECall(rest, [EIdent("null")])]);
			return EBlock([
				EVar(v, t),
				toCps(ev, EFunction([ { name : "_r", t : null } ], EBlock([
					EBinop("=", EIdent(v), EIdent("_r")),
					ECall(rest,[EIdent("null")]),
				])), exit),
			]);
		case EIdent(i) if( funNames.exists(i) ):
			return ECall(rest, [EIdent("a_" + i)]);
		case EConst(_), EIdent(_), EUnop(_), EField(_):
			return ECall(rest, [e]);
		case EFunction(_):
			return ECall(rest, [buildAsync(e)]);
		case ENew(cl, args):
			args.unshift(EConst(CString(cl)));
			return toCps(ECall(EIdent("__new__"), args), rest, exit);
		case EBreak:
			if( currentBreak == null ) throw "Break outside loop";
			return currentBreak;
		case EContinue:
			if( currentLoop == null ) throw "Continue outside loop";
			return EBlock([ECall(currentLoop, [EIdent("null")]), EReturn()]);
		case ESwitch(v, cases, def):
			var cases = [for( c in cases ) { values : c.values, expr : toCps(c.expr, rest, exit) } ];
			return toCps(v, EFunction([ { name : "_c", t : null } ], ESwitch(EIdent("_c"), cases, def == null ? retNull(rest) : toCps(def, rest, exit))), exit );
		case EThrow(v):
			return toCps(v, EFunction([ { name : "_v", t : null } ], EThrow(v)), exit);
		default:
			throw "Unsupported " + e;
		}
	}

}

class ScriptInterp extends hscript.Interp {

	override function get( o : Dynamic, f : String ) {
		if( o == null ) throw hscript.Expr.Error.EInvalidAccess(f);
		var getter = Reflect.field(o, "get_" + f);
		if( getter != null )
			return getter();
		return Reflect.field(o, f);
	}

	override function set( o : Dynamic, f : String, v : Dynamic ) {
		if( o == null ) throw hscript.Expr.Error.EInvalidAccess(f);
		var setter = Reflect.field(o, "set_" + f);
		if( setter != null )
			return setter(v);
		Reflect.setField(o, f, v);
		return v;
	}

	override function fcall( o : Dynamic, f : String, args : Array<Dynamic> ) : Dynamic {
		var m = Reflect.field(o, f);
		if( m == null ) {
			if( f.substr(0, 2) == "a_" ) {
				m = Reflect.field(o, f.substr(2));
				// fallback on sync version
				if( m != null ) {
					var onEnd = args.shift();
					onEnd(call(o, m, args));
					return null;
				}
			}
			throw o + " has no method " + f;
		}
		return call(o, m, args);
	}

}
