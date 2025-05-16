module main

import time

fn loop_inputs(code string) {
	mut input := Input.new(code)

	for !input.eof() {
		next := input.next()

		dump('next = ${next}')
	}
}

fn loop_tokens(code string) {
	mut token := Token.new(Input.new(code))

	for !token.eof() {
		dump(token.next())
	}
}

fn peek_tokens(code string, from int, to int) {
	mut token := Token.new(Input.new(code))

	for _ in from .. to {
		dump(token.peek())
		token.next()
	}
}

fn parse_code(code string) {
	mut input := Input.new(code)
	mut token := Token.new(input)
	mut parse := Parse.new(token)

	dump(parse.parse_top_level())
}

fn parse_codes(codes []string) {
	for code in codes {
		parse_code(code)
	}
}

fn eval_code(code string, env Environment) {
	mut input := Input.new(code)
	mut token := Token.new(input)
	mut parse := Parse.new(token)
	mut evaluate := Evaluate.new(parse.parse_top_level(), env)

	evaluate.eval()
}

fn new_global_env() &Environment {
	mut global_env := Environment.new(none)

	global_env.def('time', FnValue(fn (func fn ()) ?Any {
		println(time.now())
		func()
		println(time.now())
		return none
	}))

	global_env.def('println', FnValue(fn (args []Any) ?Any {
		val := args.first().as_string()
		println(val)
		return none
	}))

	global_env.def('print', FnValue(fn (args []Any) ?Any {
		val := args.first().as_string()
		print(val)
		return none
	}))

	global_env.def('is_function', FnValue(fn (args []Any) ?Any {
		status := args.first().is_function()
		println(status)
		return none
	}))

	return global_env
}

fn main() {
	parse_codes([
		'123.5;',
		'"Hello World!";',
		'true;',
		'false',
		'foo;',
		'lambda (x) 10;',
		'λ (x) 10;',
		'foo(a, 1);',
		'if foo then bar else baz;',
		'if foo then bar;',
		'a = 10;',
		'x + y * z;',
		'{ a = 5; b = a * 2; a + b; };',
	])

	// ------
	eval_code('
		println("----");
		a = 1 + 1;
		println(a);

		b = "this is a test";
		println(b);

		sum = lambda(x, y) x + y;
		sum(2, 3);
		print(sum(2, 3));

		println("\n----");
		print("123\n");
		print("456\n");
		print(lambda(x, y) x + y);

		println("\n----");
		is_function(lambda(x) x + 10);
		is_function(lambda(x, y) x + y);
		is_function("1234");
	',
		new_global_env())

	eval_code('
		println("----");
		print_range = λ(a, b) if a <= b {
			print(a);
			if a + 1 <= b {
				print(", ");
				print_range(a + 1, b);
			} else println("");
		};
		print_range(1, 10);

		println("----");
		cons = λ(a, b) λ(f) f(a, b);
		car = λ(cell) cell(λ(a, b) a);
		cdr = λ(cell) cell(λ(a, b) b);
		nil = λ(f) f(nil, nil);

		x = cons(1, cons(2, cons(3, cons(4, cons(5, nil)))));
		println(car(x));                      # 1
		println(car(cdr(x)));                 # 2
		println(car(cdr(cdr(x))));            # 3
		println(car(cdr(cdr(cdr(x)))));       # 4
		println(car(cdr(cdr(cdr(cdr(x))))));  # 5

		println("----");
		foreach = λ(list, f)
			if list != nil {
				f(car(list));
				foreach(cdr(list), f);
			};
		foreach(x, println);

		println("----");
		range = λ(a, b)
			if a <= b
			then cons(a, range(a + 1, b))
			else nil;
		# print the squares of 1..8
		foreach(range(1, 8), λ(x) println(x * x));
	',
		new_global_env())

	eval_code('
		println("----");
		cons = λ(x, y)
			λ(a, i, v)
				if a == "get"
				then if i == 0 then x else y
				else if i == 0 then x = v else y = v;

		car = λ(cell) cell("get", 0);
		cdr = λ(cell) cell("get", 1);
		set-car! = λ(cell, val) cell("set", 0, val);
		set-cdr! = λ(cell, val) cell("set", 1, val);

		# NIL can be a real cons this time
		nil = cons(0, 0);
		set-car!(nil, nil);
		set-cdr!(nil, nil);

		## test:
		x = cons(1, 2);
		println(car(x));
		println(cdr(x));
		set-car!(x, 10);
		set-cdr!(x, 20);
		println(car(x));
		println(cdr(x));
	',
		new_global_env())

	eval_code('
		println("----");
		println(let loop (n = 100)
					if n > 0
					then n + loop(n - 1)
					else 0);

		let (x = 2, y = x + 1, z = x + y)
			println(x + y + z);

		# errors out, the vars are bound to the let body
		# print(x + y + z);

		let (x = 10) {
			let (x = x * 2, y = x * x) {
				println(x);  ## 20
				println(y);  ## 400
			};
			println(x);  ## 10
		};
	',
		new_global_env())
}
