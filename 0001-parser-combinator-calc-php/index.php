<?php
class Maybe {
    public bool $hasValue = false;
    public array $value = [];
}

class Parser {
}

class Just extends Maybe {
    public function __construct(array $value) {
        $this->hasValue = true;
        $this->value    = $value;
    }
}

class Nothing extends Maybe {
    public function __construct() {
        $this->hasValue = false;
        $this->value    = [];
    }
}

function regex(string $pattern): Parser {
    return new class($pattern) extends Parser {
        public function __construct(
            protected string $pattern
        ) { }

        public function __invoke(string $input): Maybe {
            [$first, $last] = findBounds($input, $this->pattern);
    
            $result = [
                mb_substr($input, 0, $last + 1),
                mb_substr($input, $last + 1, mb_strlen($input) - 1)
            ];
    
            if ($first === 0) {
                return new Just($result);
            }else{
                return new Nothing();
            }
        }
    };
}

function map(Parser $parser, Closure $callback): Parser {
    return new class($parser, $callback) extends Parser {
        public function __construct(
            protected Parser $parser,
            protected Closure $callback,
        ) { }
        
        public function __invoke(string $input): Maybe {
            $result = ($this->parser)($input);
            
            if ($result->hasValue) {
                [$first, $last] = $result->value;
                
                return new Just([
                    ($this->callback)($first),
                    $last
                ]);
            }else{
                return new Nothing();
            }
        }
    };
}

function char(string $char): Parser {
    return new class($char) extends Parser {
        public function __construct(
            protected string $char,
        ) { }
        
        public function __invoke(string $input): Maybe {
            if (str_starts_with($input, $this->char)) {
                $first = mb_substr($input, 0, mb_strlen($this->char));
                $last  = mb_substr($input, mb_strlen($this->char), mb_strlen($input));
                
                return new Just([$first, $last]);
            }
            
            return new Nothing();
        }
    };
}

function repeat(Parser $parser): Parser {
    return new class($parser) extends Parser {
        public function __construct(
            protected Parser $parser,
        ) { }
        
        public function __invoke(string $input): ?Maybe {
            $firsts = [];
            $lasts  = $input;
            
            while(true) {
                $result = ($this->parser)($lasts);

                if ($result->hasValue) {
                    [$first, $last] = $result->value;
                    
                    $firsts[] = $first;
                    
                    $lasts = $last;
                }else{
                    return new Just([$firsts, $lasts]);
                }
            }
            
            return null;
        }
    };
}

function flatMap(Parser $parser, Closure $callback): Parser {
    return new class($parser, $callback) extends Parser {
        public function __construct(
            protected Parser $parser,
            protected Closure $callback,
        ) {
        }
        
        public function __invoke(string $input): Maybe {
            $result = ($this->parser)($input);
            
            if ($result->hasValue) {
                [$first, $last] = $result->value;

                return ($this->callback)($first)($last);
            }else{
                return new Nothing();
            }
        }
        
    };
}

function either(Parser $leftHandSide, Parser $rightHandSide): Parser {
    return new class($leftHandSide, $rightHandSide) extends Parser {
        public function __construct(
            protected Parser $leftHandSide,
            protected Parser $rightHandSide,
        ) {}
        
        public function __invoke(string $input): MayBe {
            $leftResult = ($this->leftHandSide)($input);
            
            if ($leftResult->hasValue) {
                return $leftResult;
            }else{
                return ($this->rightHandSide)($input);
            }
        }
    };
}

function both(Parser $leftHandSide, Parser $rightHandSide): Parser {
    return new class($leftHandSide, $rightHandSide) extends Parser {
        public function __construct(
            protected Parser $leftHandSide,
            protected Parser $rightHandSide,
        ) {}
        
        public function __invoke(string $input): Maybe {
            $leftResult = ($this->leftHandSide)($input);

            if ($leftResult->hasValue) {
                [$leftFirst, $leftLast] = $leftResult->value;
                
                $rightResult = ($this->rightHandSide)($leftLast);
                
                if ($rightResult->hasValue) {
                    [$rightFirst, $rightLast] = $rightResult->value;
                    
                    return new Just([
                        [$leftFirst, $rightFirst],
                        $rightLast,
                    ]);
                }else{
                    return new Nothing();
                }
            }else{
                return new Nothing();
            }
        }
    };
}

function chainLeft(Parser $term, Parser $operate): Parser {
    return map(
        both($term, repeat(both($operate, $term))),
        function(array $values) {
            [$firstValue, $lastValue] = $values;
            
            $value = $firstValue;
            foreach($lastValue as $methodBlock) {
                [$method, $block] = $methodBlock;
                
                $value = $method($value, $block);
            }

            return $value;
        }
    );
}

//
function findBounds(string $input, string $pattern) {
    preg_match($pattern, $input, $matches, PREG_OFFSET_CAPTURE);
    
    $matchedTextStartAt = -1;
    $matchedTextEndAt   = 0;
    
    if (!empty($matches)) {
        $matchedText        = $matches[0][0];
        $matchedTextStartAt = $matches[0][1];
        $matchedTextEndAt   = $matchedTextStartAt + (mb_strlen($matchedText) - 1);
    }
    
    return [$matchedTextStartAt, $matchedTextEndAt];
}

//
function number(): Parser {
    return map(regex("/[0-9]+/"), fn(string $value): int => floatval($value));
}

function expression(): Parser {
    return addOp();
}

function addOp(): Parser {
    return chainLeft(
        mulOp(),
        either(
            map(char("+"), function(string $value): Closure {
                return fn(int $left, int $right) => $left + $right;
            }),
            map(char("-"), function(string $value): Closure {
                return fn(int $left, int $right) => $left - $right;
            }),
        )
    );
}

function mulOp(): Parser {
    return chainLeft(
        factor(),
        either(
            map(char("*"), function(string $value): Closure {
                return fn(int $left, int $right) => $left * $right;
            }),
            map(char("/"), function(string $value): Closure {
                return fn(int $left, int $right) => $left / $right;
            }),
        )
    );
}

function factor(): Parser {
    return either(
        flatMap(char("("), function(string $_): Parser {
            return flatMap(expression(), function(int $e): Parser {
                return map(char(")"), function(string $_) use ($e): int {
                    return $e;
                });
            });
        }),
        number()
    );
}

//
print_r([
    expression()("(1+2)*(3+4)"), // 21
    expression()("1+(2*4)/2"),   // 5
]);