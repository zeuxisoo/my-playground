module main

type FnValue = fn () | fn ([]Any) ?Any | fn (fn ()) ?Any | fn (fn ([]Any)) ?Any

type Any = FnValue | bool | f32 | f64 | i64 | int | string

fn (a Any) as_string() string {
	return match a {
		bool {
			if a {
				'true'
			} else {
				'false'
			}
		}
		f32, f64, i64, int {
			a.str()
		}
		string {
			a
		}
		FnValue {
			a.as_string()
		}
	}
}

fn (a Any) as_function() FnValue {
	return a as FnValue
}

fn (a Any) is_function() bool {
	return a is FnValue
}

fn (fv FnValue) as_string() string {
	/* nothing todo for lambda function without call stack
	$for v in fv.variants {
		$if v.typ is fn ([]Any) ?Any {
			dump(v)
		}
	}

	$for m in fv.methods {
		dump(m)
	}
	*/

	return match fv {
		fn (), fn ([]Any) ?Any, fn (fn ()) ?Any, fn (fn ([]Any)) ?Any {
			'${fv.str()} (0x${ptr_str(fv)})'
		}
	}
}

/* nothing todo for lambda function without call stack
fn (fv FnValue) reflect[T]() T {
	mut r := T{}
	return r
}
*/
