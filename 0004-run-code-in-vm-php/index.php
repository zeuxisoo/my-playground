<?php
enum OpCode: int {
    case Constant  = 0;
    case Add = 1;
    case Sub = 2;
    case Mul = 3;
    case Div = 4;
    case Negate = 5;
    case Return = 6;
}

enum InterpretResult: int {
    case Ok = 0;
    case CompileError = 1;
    case RuntimeError = 2;
}

class Debug {
    
    public static function constantInstruction(string $name, int $location, Chunk $chunk) {
        $constant = $chunk->code[$location + 1]->value;
        
        printf("%-16s %4d '", $name, $constant);
        printf("%s", $chunk->constants[$constant]);
        printf("'");
    }
    
    public static function simpleInstruction(string $name, int $location) {
        printf("%-16s %5s ", $name, "");
    }
    
}

class Chunk {
    
    public function __construct(
        public array $code = [],
        public array $constants = [],
        protected array $lines = [],
        protected array $locations = []
    ) { }
        
    public function addConstant(int|float $value): int {        
        $this->constants[] = $value;

        return count($this->constants) - 1;
    }
    
    public function write(OpCode $byte, int $line): void {
        $totalLine = count($this->lines);

        if ($totalLine === 0 || $this->lines[$totalLine - 1] !== $line) {
            $this->lines[] = $line;
            $this->locations[] = count($this->code);
        }

        $this->code[] = $byte;
    }
        
    public function writeConstant(int|float $value, int $line): void {
        $constant = $this->addConstant($value);
        
        $this->writeOp(OpCode::Constant, $line);
        $this->write(OpCode::from($constant), $line);
    }
    
    public function writeOp(OpCode $opCode, int $line): void {
        $this->write($opCode, $line);
    }
    
    public function disassembleInstruction(int $location): int {
        $line        = $this->getLine($location);
        $instruction = $this->code[$location];

        $instructionSize = match($instruction) {
            OpCode::Constant => 2,
            default => 1
        };
        
        printf("%06d ", $location);
        for($i = 0; $i < $instructionSize; $i++) {
            printf("%02d ", $this->code[$location + $i]->value);
        }
        
        for($i = $instructionSize; $i < 4; $i++) {
            echo "   ";
        }
        
        if ($location > 0 && $line === $this->getLine($location - 1)) {
            echo "    |  ";
        }else{
            printf("%5d  ", $line);
        }
        
        switch($instruction) {
            case OpCode::Constant:
                Debug::constantInstruction("OpCodeConstant", $location, $this);
                break;
            case OpCode::Add:
                Debug::simpleInstruction("OpCodeAdd", $location);
                break;
            case OpCode::Sub:
                Debug::simpleInstruction("OpCodeSub", $location);
                break;
            case OpCode::Mul:
                Debug::simpleInstruction("OpCodeMul", $location);
                break;
            case OpCode::Div:
                Debug::simpleInstruction("OpCodeDiv", $location);
                break;
            case OpCode::Negate:
                Debug::simpleInstruction("OpCodeNegate", $location);
                break;
            case OpCode::Return:
                Debug::simpleInstruction("OpCodeReturn", $location);
                break;
        }

        return $location + $instructionSize;
    }
    
    protected function getLine(int $location): int {
        $found = false;
        
        [$low, $mid, $high] = [0, 0, count($this->lines) - 1];
        
        while($low <= $high) {
            $mid = ($low + $high) / 2;
            
            if ($location < $this->locations[$mid]) {
                $high = $mid;
            }else if ($location > $this->locations[$mid]) {
                $low = $mid + 1;
            }else{
                $found = true;
                break;
            }
        }
        
        if (!$found && $location <= $this->locations[$mid]) {
            $mid = $mid - 1;
        }
        
        return $this->lines[$mid];
    }
    
}

class VM {
    
    protected Chunk $chunk;
    protected int $location;
    protected array $stack;
    
    public function __construct() {
        $this->stack = [];
    }
    
    public function interpret(Chunk $chunk): InterpretResult {
        $this->chunk    = $chunk;
        $this->location = 0;
        
        return $this->run();
    }
    
    public function run(): InterpretResult {
        while(true) {
            if (count($this->stack) !== 0) {
                echo "\t[ ".implode(" , ", $this->stack)." ]\n";
            }
            
            $this->chunk->disassembleInstruction($this->location);
            
            $instruction = $this->next();
            
            switch($instruction) {
                case OpCode::Constant:
                    $this->push($this->readConstant());
                    break;
                case OpCode::Add:
                    $right = $this->pop();
                    $left  = $this->pop();
                    
                    $this->push($left + $right);
                    break;
                case OpCode::Sub:
                    $right = $this->pop();
                    $left  = $this->pop();
                
                    $this->push($left - $right);
                    break;
                case OpCode::Mul:
                    $right = $this->pop();
                    $left  = $this->pop();

                    $this->push($left * $right);
                    break;
                case OpCode::Div:
                    $right = $this->pop();
                    $left  = $this->pop();
                    
                    $this->push($left / $right);
                    break;
                case OpCode::Negate:
                    $this->push(-$this->pop());
                    break;
                case OpCode::Return:
                    $result = $this->pop();
                    
                    if (count($this->stack) !== 0) {
                        echo "\t[ ".implode(" , ", $this->stack)." ]\n";
                    }

                    echo "\n\nResult: ",$result,"\n";
                    
                    return InterpretResult::Ok;
            }
        }
    }
    
    public function next(): OpCode {
        $instruction = $this->chunk->code[$this->location];
        
        $this->location++;
        
        return $instruction;
    }
    
    public function push(int|float $value): void {
        $this->stack[] = $value;
    }
    
    public function pop(): int|float {
        $value = array_pop($this->stack);

        return $value;
    }
    
    public function readConstant(): int|float {
        return $this->chunk->constants[$this->next()->value];
    }
    
}

function main(): void {
    $chunk = new Chunk();
    
    // 1.2 + 3.4 = 4.6
    $chunk->writeConstant(value: 1.2, line: 87);
    $chunk->writeConstant(value: 3.4, line: 87);
    $chunk->writeOp(
        opCode: OpCode::Add, 
        line  : 87
    );

    // 4.6 / 2 = 2.3
    $chunk->writeConstant(value: 2, line: 87);
    $chunk->writeOp(
        opCode: OpCode::Div,
        line  : 87
    );
    
    // 2.3 * 10 = 23
    $chunk->writeConstant(value: 10, line: 87);
    $chunk->writeOp(
        opCode: OpCode::Mul,
        line  : 87
    );
    
    // 23 - 1.5 - 1.5 = 20
    for($i=0; $i<2; $i++) {
        $chunk->writeConstant(value: 1.5, line: 87);
        $chunk->writeOp(
            opCode: OpCode::Sub,
            line  : 87
        );
    }
    
    // 20 => -20
    $chunk->writeOp(OpCode::Negate, 87);
    
    // -20
    $chunk->writeOp(OpCode::Return, 87);
    
    // Run
    $vm = new VM();
    $vm->interpret($chunk);
}

main();