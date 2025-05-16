class NodeNames {

    constructor() {
        this.isCycle = {};
        this.names   = {};
    }

    isPartOfCycle(name, alreadySeen = []) {
        let seen = false;
        let newAlreadySeen = [...alreadySeen];

        if (this.isCycle[name]) {
            return [this.isCycle[name], newAlreadySeen];
        }

        if (alreadySeen.includes(name)) {
            newAlreadySeen.push(name);

            this.isCycle[name] = true;

            return [true, newAlreadySeen];
        }

        newAlreadySeen.push(name);

        const deps = this.names[name];

        if (deps.length === 0) {
            this.isCycle[name] = false;

            return [false, newAlreadySeen];
        }

        for(const dep of deps) {
            let depAlreadySeen = [...newAlreadySeen];

            [seen, depAlreadySeen] = this.isPartOfCycle(dep, depAlreadySeen);

            if (seen) {
                newAlreadySeen = [...depAlreadySeen];

                this.isCycle[name] = true;

                return [true, newAlreadySeen];
            }
        }

        this.isCycle[name] = false;

        return [false, newAlreadySeen];
    }

}

export default NodeNames;
