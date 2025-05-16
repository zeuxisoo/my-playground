import DepGraphNode from './dep-graph-node.js';
import OrderedDepMap from './ordered-dep-map.js';
import NodeNames from './node-names.js';

class DepGraph {

    constructor() {
        this.acyclic = true;
        this.nodes   = [];
        this.values  = {};
    }

    add(name, deps = []) {
        const newNode = new DepGraphNode({ name, deps });

        this.nodes.push(newNode);
        this.values[name] = 0;
    }

    addWithValue(name, deps, value) {
        const newNode = new DepGraphNode({ name, value, deps });

        this.nodes.push(newNode);
        this.values[name] = value;
    }

    resolve() {
        const nodeNames = new OrderedDepMap();
        const nodeDeps  = new OrderedDepMap();

        for(const node of this.nodes) {
            nodeNames.add(node.name, node.deps);
            nodeDeps.add(node.name, node.deps);
        }

        let iterations = 0;
        const resolved = new DepGraph();

        while(nodeDeps.size() !== 0) {
            iterations++;

            const readySet = [];

            for(const name of nodeDeps.keys) {
                const deps = nodeDeps.get(name);

                if (deps.length === 0) {
                    readySet.push(name);
                }
            }

            if (readySet.length === 0) {
                const graph = new DepGraph();
                graph.acyclic = false;

                for(const name of nodeDeps.keys) {
                    graph.addWithValue(name, nodeNames.get(name), this.values[name]);
                }

                return graph;
            }

            for(const name of readySet) {
                nodeDeps.delete(name);

                const resolvedDeps = nodeNames.get(name);

                resolved.addWithValue(name, resolvedDeps, this.values[name]);
            }

            for(const name of nodeDeps.keys) {
                nodeDeps.applyDiff(name, readySet);
            }
        }

        return resolved;
    }

    lastNode() {
        return this.nodes[this.nodes.length - 1];
    }

    display() {
        const out = [];

        for(const node of this.nodes) {
            for(const dep of node.deps) {
                out.push(` * ${node.name} -> ${dep}`);
            }
        }

        return out.join("\n");
    }

    displayCycles() {
        let seen = false;
        const out = [];
        const nodeNames = new NodeNames();

        for(const node of this.nodes) {
            nodeNames.names[node.name] = node.deps;
        }

        for(const [key, _] in nodeNames.names) {
            let cycleNames = [];

            if (nodeNames.isCycle[key]) {
                continue;
            }

            [seen, cycleNames] = nodeNames.isPartOfCycle(key, cycleNames);

            if (seen) {
                out.push(` * ${cycleNames.join(' -> ')}`);

                nodeNames.isCycle = {};
            }
        }

        return out.join('\n');
    }

}

export default DepGraph;
