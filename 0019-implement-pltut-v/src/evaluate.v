module main

import strconv
import math

struct Evaluate {
	exp Expression
mut:
	env Environment
}

fn Evaluate.new(exp Expression, env Environment) Evaluate {
	return Evaluate{
		exp: exp
		env: env
	}
}

pub fn (mut e Evaluate) eval() {
	e.eval_exp(e.exp, mut e.env)
}

fn (e Evaluate) eval_exp(exp Expression, mut env Environment) ?Any {
	exp_kind := exp.kind

	match exp_kind {
		.prog {
			prog := exp as Program

			for p in prog.prog {
				e.eval_exp(p, mut env)
			}

			return none
		}
		.call {
			call := exp as CallExpression
			call_func := e.eval_exp(call.func, mut env) or { panic('Unknown call func expression') }

			func := if call_func is FnValue {
				call_func
			} else {
				panic('Call function is not type of FnValue')
			}

			mut args := []Any{}
			for arg in call.args {
				args << e.eval_exp(arg, mut env) or { panic('Unknown call arguments expression') }
			}

			if func is fn () {
				func()
				panic('Invalid call function `func()`')
			}

			if func is fn (args []Any) ?Any {
				return func(args)
			}

			if func is fn (func fn ()) ?Any {
				first_arg := args[0] or {
					panic('Invalid call function `fn(func)`, it require at least one parameter')
				}

				if first_arg is FnValue {
					if first_arg is fn () {
						return func(first_arg)
					}

					panic('Invalid call function `fn(func)`, the type of argument expected `fn()`, but got `${first_arg.type_name()}`')
				} else {
					panic('Invalid call function `fn(func)`, the parameter is not type of function')
				}
			}

			panic('Unknown call expression: ${func}')
		}
		.assign {
			assign := exp as AssignExpression

			if assign.left is VarExpression {
				eval_value := e.eval_exp(assign.right, mut env) or {
					panic('Unknown assign value expression')
				}

				assigned_value := env.set(assign.left.value, eval_value)

				return assigned_value
			}

			panic('Invalid expression in left-hand side expected `VarExpression` got `${assign.left.type_name()}`')
		}
		.binary {
			binary := exp as BinaryExpression
			lhs := e.eval_exp(binary.left, mut env) or {
				panic('Unknown left-hand side value in binary expression')
			}
			rhs := e.eval_exp(binary.right, mut env) or {
				panic('Unknown right-hand side value in binary expression')
			}

			return e.apply_op(binary.operator, lhs, rhs)
		}
		.@if {
			if_ := exp as IfExpression
			cond := e.eval_exp(if_.cond, mut env) or { panic('Unknown if condition expression') } as bool

			if cond != false {
				return e.eval_exp(if_.then, mut env)
			}

			if if_.@else != none {
				return e.eval_exp(if_.@else?, mut env)
			} else {
				return 'false'
			}
		}
		.bool {
			return (exp as BoolExpression).value
		}
		.lambda {
			/*
			lambda := exp as LambdaExpression

			wrapper := if lambda_name := lambda.name {
				mut scope := env.extend()

				func := e.make_lambda(mut env, exp)

				scope.def(lambda_name, func)

				env = scope.clone() // clone to fix assign causing circular loop

				func
			}else{
				e.make_lambda(mut env, exp)
			}

			return wrapper
			*/
			return e.make_lambda(mut env, exp)
		}
		.var {
			var_name := (exp as VarExpression).value
			def_value := env.get(var_name)

			return def_value
		}
		.vardef {
			panic('Should not be here: .vardef')
		}
		.let {
			let := exp as LetExpression

			// mut outside_scope := env.clone() // clone first
			mut outside_scope := env

			for v in let.vars {
				mut scope := outside_scope.extend()

				definition := v as VarDefExpression
				definition_name := (definition.name as VarExpression).value

				if definition_def := definition.def {
					definition_def_value := e.eval_exp(definition_def, mut outside_scope) or {
						panic('Cannot eval let arguments')
					}

					scope.def(definition_name, definition_def_value)
				} else {
					scope.def(definition_name, false)
				}

				// outside_scope = scope.clone() // for clone first
				outside_scope = *scope.clone() // clone to fix assign causing circular loop
			}

			return e.eval_exp(let.body, mut outside_scope)
		}
		.num {
			return (exp as NumExpression).value
		}
		.str {
			return (exp as StrExpression).value
		}
	}
}

fn (e Evaluate) apply_op(operator string, left Any, right Any) Any {
	// simply implement `float operator float` expression, no `int operator float`, `float operator int` etc
	num := fn (value Any) f64 {
		str_value := value.as_string()

		return strconv.atof64(str_value) or { panic('Cannot cast string `${str_value}` to f64') }
	}

	div := fn [num] (value Any) f64 {
		num_value := num(value)

		if num_value == 0 {
			panic('Cannot divide by zero')
		}

		return num_value
	}

	boolean := fn (value Any) bool {
		if value is bool {
			return value
		}

		panic('Cannot cast ${value} to boolean')
	}

	return match operator {
		'+' {
			num(left) + num(right)
		}
		'-' {
			num(left) - num(right)
		}
		'*' {
			num(left) * num(right)
		}
		'/' {
			num(left) / num(right)
		}
		'%' {
			math.fmod(num(left), div(right))
		}
		'&&' {
			if boolean(left) != false {
				right
			} else {
				false
			}
		}
		'||' {
			if boolean(left) != false {
				left
			} else {
				right
			}
		}
		'<' {
			num(left) < num(right)
		}
		'>' {
			num(left) > num(right)
		}
		'<=' {
			num(left) <= num(right)
		}
		'>=' {
			num(left) >= num(right)
		}
		'==' {
			if left is FnValue && right is FnValue {
				return left.as_string() != right.as_string()
			}

			left == right
		}
		'!=' {
			if left is FnValue && right is FnValue {
				return left.as_string() != right.as_string()
			}

			left != right
		}
		else {
			panic('Cannot apply operator `${operator}`')
		}
	}
}

fn (e Evaluate) make_lambda(mut env Environment, exp Expression) FnValue {
	lambda := exp as LambdaExpression

	// create outside scope for `let` expression if lambda expression has name
	mut outside_scope := env

	if lambda_name := lambda.name {
		outside_scope = *env.extend()
		outside_scope.def(lambda_name, '') // placeholder
	}

	// passthrough outside value (`e`, `env`, `lambda`) to function,
	// the `env` is unrelationship with `outside_env`
	func := fn [e, mut env, lambda] (args []Any) ?Any {
		names := lambda.vars

		mut scope := env.extend()

		for i, name in names {
			var := name as VarExpression

			scope.def(var.value, args[i] or {
				// auto fill the default value when missing arguments
				// e.g. `fn = (a, i, v)` support `fn(1, 2)` == `fn(1, 2, false)`
				false
			})
		}

		eval_value := e.eval_exp(lambda.body, mut scope)

		return eval_value
	}

	if lambda_name := lambda.name {
		outside_scope.def(lambda_name, FnValue(func)) // overwrite placeholder
	}

	env = outside_scope.clone() // clone to fix assign causing circular loop

	return func
}
