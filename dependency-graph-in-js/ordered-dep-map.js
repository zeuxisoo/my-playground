class OrderedDepMap {

    constructor() {
        this.keys = []
        this.data = {}
    }

    set(name, deps = []) {
        if (!this.data[name]) {
            this.keys.push(name);
        }

        this.data[name] = deps;
    }

    add(name, deps = []) {
        const d = this.get(name);

        for(const dep of deps) {
            if (!d.includes(dep)) {
                d.push(dep);
            }
        }

        this.set(name, d);
    }

    get(name) {
        return this.data[name] ?? [];
    }

    delete(name) {
        if (!this.data[name]) {
            throw new Error(`OrderedDepMap delete not found key name: ${name}`);
        }

        this.keys = this.keys.filter(item => {
            return item !== name
        });

        delete this.data[name];
    }

    applyDiff(name, deps = []) {
        const diff = [];
        const depsOfName = this.get(name);

        for(const dep of depsOfName) {
            if (!deps.includes(dep)) {
                diff.push(dep);
            }
        }

        this.set(name, diff);
    }

    size() {
        return this.data.length;
    }

}

export default OrderedDepMap;
