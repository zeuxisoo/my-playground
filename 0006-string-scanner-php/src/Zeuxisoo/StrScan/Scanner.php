<?php
namespace Zeuxisoo\StrScan;

class Scanner {

    public array $position_history = [];
    public int $current_position = 0;

    public array $match_history = [];
    public array $current_match = [];

    public function __construct(
        public string $text
    ) {
        $this->position_history = [0];
        $this->current_position = 0;

        $this->match_history = [];
        $this->current_match = [];
    }

    public function scan(string $pattern): null|string|int {
        return $this->scanFull($pattern);
    }

    public function scanFull(string $pattern, bool $move_position = true, bool $return_string = true): null|string|int {
        // e.g. '/stri/' => '/^stri/'
        $pattern = mb_substr($pattern, 0, 1).'^'.mb_substr($pattern, 1);

        // e.g. 'test string'[5] => 'string'
        $remain_text = mb_substr($this->text, $this->current_position);

        // e.g. using '/^stri/' find at 'string'
        $result = preg_match($pattern, $remain_text, $matches, PREG_OFFSET_CAPTURE, 0);

        if ($result === 0) {
            return null;
        }

        // (matched start position + matched value length) - current position
        $match_value_length = $matches[0][1] + mb_strlen($matches[0][0]);
        $match_value_end_position = $match_value_length - $this->current_position;

        $this->setMatchHistory([
            'value' => $matches[0][0],
            'start' => $this->current_position,
            'end'   => $this->current_position + mb_strlen($matches[0][0]),
        ]);

        if ($move_position) {
            $this->setCurrentPosition($this->current_position + $match_value_length);
        }

        if ($return_string) {
            return $matches[0][0];
        }

        return mb_strlen($matches[0][0]);
    }

    public function scanUntil(string $pattern): null|string|int {
        return $this->searchFull($pattern);
    }

    public function searchFull(string $pattern, $move_position = true, $return_string = true): null|string|int {
        $result = preg_match($pattern, $this->text, $matches, PREG_OFFSET_CAPTURE, $this->current_position);

        if ($result === 0) {
            return null;
        }

        $start_position = $this->current_position;

        // (matched start position + matched value length) - current position
        $match_value_length = $matches[0][1] + mb_strlen($matches[0][0]);
        $match_value_end_position = $match_value_length - $start_position;

        $this->setMatchHistory([
            'value' => $matches[0][0],
            'start' => $matches[0][1],
            'end'   => $match_value_end_position,
        ]);

        if ($move_position) {
            $this->setCurrentPosition($match_value_end_position);
        }

        if ($return_string) {
            return mb_substr($this->text, $start_position, $match_value_end_position);
        }

        return $match_value_length - $start_position;
    }

    public function scanUpto(string $pattern): null|string {
        $position = $this->current_position;

        if ($this->scanUntil($pattern) !== null) {
            $current_scan_position = $this->current_position - mb_strlen($this->matched()) + 1;

            $this->setCurrentPosition($current_scan_position);

            array_pop($this->position_history);

            return mb_substr($this->preMatch(), $position);
        }

        return null;
    }

    public function skip(string $pattern): null|int {
        return $this->scanFull($pattern, $move_position=true, $return_string=false);
    }

    public function skipUntil(string $pattern): null|int {
        return $this->searchFull($pattern, $move_position=true, $return_string=false);
    }

    public function check(string $pattern): null|string {
        return $this->scanFull($pattern, $move_position=false, $return_string=true);
    }

    public function checkUntil(string $pattern): null|string {
        return $this->searchFull($pattern, $move_position=false, $return_string=true);
    }

    public function exists(string $pattern): null|int {
        return $this->searchFull($pattern, $move_position=false, $return_string=false);
    }

    public function unScan(): void {
        array_pop($this->position_history);
        $this->current_position = count($this->position_history) ? end($this->position_history) : [];

        array_pop($this->match_history);
        $this->current_match = count($this->match_history) > 0 ? end($this->match_history) : [];
    }

    //
    public function beginOfLine(): null|bool {
        if ($this->current_position > mb_strlen($this->text)) {
            return null;
        }

        if ($this->current_position === 0) {
            return true;
        }

        return mb_substr($this->text, $this->current_position - 1, 1) === "\n";
    }

    public function eos(): bool {
        return mb_strlen($this->text) === $this->current_position;
    }

    public function getChar(): string {
        $this->setCurrentPosition($this->current_position + 1);

        return mb_substr($this->text, $this->current_position - 1, 1);
    }

    public function peek(int $length): string {
        return mb_substr($this->text, $this->current_position, $this->current_position + $length);
    }

    public function rest(): string {
        return mb_substr($this->text, $this->current_position);
    }

    public function matched(): string {
        return $this->current_match['value'];
    }

    public function preMatch(): string {
        return mb_substr($this->text, 0, $this->current_match['start']);
    }

    public function postMatch(): string {
        return mb_substr($this->text, $this->current_match['end']);
    }

    public function coords(): object {
        return calculateCoords($this->text, $this->current_position);
    }

    //
    public function setCurrentPosition(int $value): void {
        $this->current_position = $value;
        $this->position_history[] = $value;
    }

    public function setMatchHistory(array $value): void {
        $this->current_match = $value;
        $this->match_history[] = $value;
    }

    public function terminate(): void {
        $this->setCurrentPosition(mb_strlen($this->text));
        $this->current_match = [];
    }

}

function calculateCoords(string $text, int $position): object {
    // (if mb_strrpos not found and got false, set index to -1, otherwise, got right index) + 1
    $line_start    = (mb_strrpos(mb_substr($text, 0, $position), "\n") ?: -1) + 1;
    $line_end      = mb_strpos($text, "\n", $position);
    $line_number   = mb_substr_count(mb_substr($text, 0, $position), "\n");
    $column_number = $position - $line_start;

    // only select [start:end] not [start:strlen]
    $line = mb_substr($text, $line_start, $line_end - $line_start);

    return new class($line_number, $column_number, $line) {
        public function __construct(
            public int $line_number,
            public int $column_number,
            public string $line,
        ) {}
    };
}
