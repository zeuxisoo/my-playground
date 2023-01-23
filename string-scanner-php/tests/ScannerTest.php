<?php
declare(strict_types=1);

namespace Zeuxisoo\StrScan\Tests;

use Zeuxisoo\StrScan\Scanner;

class ScannerTest extends TestCase {

    protected ?Scanner $scanner;

    protected function setUp(): void {
        $this->scanner = new Scanner("test string");
    }

    protected function tearDown(): void {
        $this->scanner = null;
    }

    public function testSearchFull(): void {
        $data = [
            'expected' => ['test ', '5', 'stri', 5, 4, 5],
            'actual'   => [
                $this->scanner->searchFull("/ /"),
                $this->scanner->current_position,
                $this->scanner->searchFull("/i/", $move_position=false),
                $this->scanner->current_position,
                $this->scanner->searchFull("/i/", $move_position=false, $return_string=false),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testScan(): void {
        $data = [
            'expected' => [0, '', '', 0, 'test ', 5],
            'actual'   => [
                $this->scanner->current_position,
                $this->scanner->scanFull("/foo/"),
                $this->scanner->scanFull("/bar/"),
                $this->scanner->current_position,
                $this->scanner->scanFull("/test /"),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testScanUntil(): void {
        $data = [
            'expected' => [0, '', '', 0, 'test ', 5],
            'actual'   => [
                $this->scanner->current_position,
                $this->scanner->scanUntil("/foo/"),
                $this->scanner->scanUntil("/bar/"),
                $this->scanner->current_position,
                $this->scanner->scanUntil("/ /"),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testScanFull(): void {
        $data = [
            'expected' => ['', 'test ', 5, 'stri', 5, 4, 5],
            'actual'   => [
                $this->scanner->scanFull("/ /"),
                $this->scanner->scanFull("/test /"),
                $this->scanner->current_position,
                $this->scanner->scanFull("/stri/", $move_position=false),
                $this->scanner->current_position,
                $this->scanner->scanFull("/stri/", $move_position=false, $return_string=false),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testScanUpto(): void {
        $data = [
            'expected' => ['t', 'est', 4, [0,1,4]],
            'actual'   => [
                $this->scanner->scan("/t/"),
                $this->scanner->scanUpto("/ /"),
                $this->scanner->current_position,
                $this->scanner->position_history,
            ]
        ];

        $this->runEqualsBatch($data);
    }

    public function testMatched(): void {
        $data = [
            'expected' => ['test', 'test'],
            'actual'   => [
                $this->scanner->scan("/test/"),
                $this->scanner->matched(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testSkip(): void {
        $data = [
            'expected' => [5],
            'actual'   => [
                $this->scanner->skip("/test /"),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testSkipUntil(): void {
        $data = [
            'expected' => [5],
            'actual'   => [
                $this->scanner->skipUntil("/ /"),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testCheck(): void {
        $data = [
            'expected' => ['test ', 0],
            'actual'   => [
                $this->scanner->check("/test /"),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testCheckUntil(): void {
        $data = [
            'expected' => ['test ', 0],
            'actual'   => [
                $this->scanner->checkUntil("/ /"),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testExists(): void {
        $data = [
            'expected' => [5, 0],
            'actual'   => [
                $this->scanner->exists("/ /"),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testUnScan(): void {
        $data = [
            'expected' => [0, 2, 'st string', '', 0, 'test string'],
            'actual'   => [
                $this->scanner->current_position,
                $this->scanner->skip("/te/"),
                $this->scanner->rest(),
                $this->scanner->unScan(),
                $this->scanner->current_position,
                $this->scanner->rest(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testEos(): void {
        $data = [
            'expected' => [false, '', true],
            'actual'   => [
                $this->scanner->eos(),
                $this->scanner->terminate(),
                $this->scanner->eos(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testBeginOfLine(): void {
        $this->scanner->text = "test\ntest\n";

        $data = [
            'expected' => [true, 2, false, 3, true, '', true],
            'actual'   => [
                $this->scanner->beginOfLine(),
                $this->scanner->skip("/te/"),
                $this->scanner->beginOfLine(),
                $this->scanner->skip("/st\n/"),
                $this->scanner->beginOfLine(),
                $this->scanner->terminate(),
                $this->scanner->beginOfLine(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testGetChar(): void {
        $this->scanner->text = "abc\n";

        $data = [
            'expected' => ["a", "b", "c", 3],
            'actual'   => [
                $this->scanner->getChar(),
                $this->scanner->getChar(),
                $this->scanner->getChar(),
                $this->scanner->current_position,
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testPeek(): void {
        $data = [
            'expected' => ["test st", "test st"],
            'actual'   => [
                $this->scanner->peek(7),
                $this->scanner->peek(7),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testRest(): void {
        $data = [
            'expected' => ["test", " string"],
            'actual'   => [
                $this->scanner->scan("/test/"),
                $this->scanner->rest(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testPreMatch(): void {
        $data = [
            'expected' => [4, " ", "test"],
            'actual'   => [
                $this->scanner->skip("/test/"),
                $this->scanner->scan("/\s/"),
                $this->scanner->preMatch(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testPostMatch(): void {
        $data = [
            'expected' => [4, " ", "string"],
            'actual'   => [
                $this->scanner->skip("/test/"),
                $this->scanner->scan("/\s/"),
                $this->scanner->postMatch(),
            ],
        ];

        $this->runEqualsBatch($data);
    }

    public function testCoords(): void {
        $this->scanner->text = "abcdef\nghijkl\nmnopqr\nstuvwx\nyz";

        $create_coords = function(int $line_number, int $column_number, string $line): object {
            return new class($line_number, $column_number, $line) {
                public function __construct(
                    public int $line_number,
                    public int $column_number,
                    public string $line,
                ) { }
            };
        };

        $data = [
            'expected' => [
                $create_coords(0, 0, 'abcdef'),
                '',
                $create_coords(0, 4, 'abcdef'),
                '',
                $create_coords(0, 6, 'abcdef'),
                '',
                $create_coords(1, 0, 'ghijkl'),
                '',
                $create_coords(1, 4, 'ghijkl'),
                '',
                $create_coords(2, 1, 'mnopqr'),
            ],
            'actual'   => [
                $this->scanner->coords(),
                $this->scanner->setCurrentPosition($this->scanner->current_position + 4),
                $this->scanner->coords(),
                $this->scanner->setCurrentPosition($this->scanner->current_position + 2),
                $this->scanner->coords(),
                $this->scanner->setCurrentPosition($this->scanner->current_position + 1),
                $this->scanner->coords(),
                $this->scanner->setCurrentPosition($this->scanner->current_position + 4),
                $this->scanner->coords(),
                $this->scanner->setCurrentPosition($this->scanner->current_position + 4),
                $this->scanner->coords(),
            ],
        ];

        $this->runEqualsCoordsBatch($data);
    }

    // Helper
    protected function runEqualsBatch(array $data): void {
        $expected_list = $data['expected'];
        $actual_list   = $data['actual'];

        foreach($expected_list as $index => $expected) {
            $this->assertEquals($expected, $actual_list[$index]);
        }
    }

    protected function runEqualsCoordsBatch(array $data): void {
        $expected_list = $data['expected'];
        $actual_list   = $data['actual'];

        foreach($expected_list as $index => $expected) {
            if (is_object($expected)) {
                $actual = $actual_list[$index];

                $this->assertEquals($expected->line_number,   $actual->line_number);
                $this->assertEquals($expected->column_number, $actual->column_number);
                $this->assertEquals($expected->line,          $actual->line);
            }else{
                $this->assertEquals($expected, $actual_list[$index]);
            }
        }
    }

}
