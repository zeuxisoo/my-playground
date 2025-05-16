class DepGraphNode {

    constructor({ name, value, deps }) {
        this.name  = name;
        this.value = value ?? 0;
        this.deps  = deps;
    }

}

export default DepGraphNode;
