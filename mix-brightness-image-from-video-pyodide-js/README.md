# Maxone

Mix the highest brightness image from selected video frames

# Requirements

- node v16.14.2
- see `package.json` (e.g. pyodide)
- iOS 14 may not work

# Testing

Run in console

```
make server
```

# Build

Run in console

```
make build
php -S localhost:8080 -t ./dist
```

or

```
python3 -m http.server 8080 [-b 127.0.0.1]
```
