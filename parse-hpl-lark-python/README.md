# Parse Streamline .hpl in Python (lark)

:)

## Requirements

- Python v3.9.6

## Testing

Create virtual environment, install dependencies and activate environment

```
make venv
make vendor
source venv/bin/activate
```

Show the parsed tree or pretty print

```
python3 main.py --parse
python3 main.py --pretty
```

Show the walked result or base on selected walker

```
python3 main.py
python3 main.py --walker=[1-4]
```

Run the benchmark

```
make benchmark
```
