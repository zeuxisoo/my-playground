module main

@[heap]
struct Environment {
pub mut:
	vars   map[string]Any
	parent ?&Environment
}

fn Environment.new(parent ?&Environment) &Environment {
	mut env := &Environment{
		// vars: if parent != none {
		// 	parent.vars.clone()
		// } else {
		// 	map[string]Any{}
		// }
		vars:   map[string]Any{}
		parent: parent
	}

	return env
}

pub fn (mut e Environment) extend() &Environment {
	return Environment.new(e)
}

// lookup environment and return it by reference
pub fn (mut e Environment) lookup(name string) ?&Environment {
	mut scope := e

	if name in scope.vars {
		return &scope
	}

	for scope.parent != none {
		scope = *scope.parent?

		if name in scope.vars {
			return &scope
		}
	}

	return none
}

pub fn (mut e Environment) get(name string) Any {
	// support change parent scope variable (e.g. `wrapper(x) { func(y) { x = y } }`)
	// 1. missing `let` syntax
	// 2. the `new/1` method is `vars: map[string]Any{}` only
	mut scope := e.lookup(name) or { panic('Undefined variable: ${name}') }

	return scope.vars[name] or { panic('Cannot get variable: ${name}') }
}

fn (mut e Environment) set(name string, value Any) Any {
	mut scope := e.lookup(name) or { e }

	scope.vars[name] = value

	return value
}

pub fn (mut e Environment) def(name string, value Any) Any {
	e.vars[name] = value

	return value
}

pub fn (mut e Environment) clone() &Environment {
	mut cloned := &Environment{
		vars:   e.vars.clone()
		parent: none
	}

	if mut parent := e.parent {
		cloned.parent = parent.clone()
	} else {
		cloned.parent = none
	}

	return cloned
}
