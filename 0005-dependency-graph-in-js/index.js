import DepGraph from "./dep-graph.js";
import OrderedDepMap from "./ordered-dep-map.js";

function showDepGraph() {
    const g = new DepGraph();

    g.add("a", ["b"]);
    console.dir(g, { depth: null });

    g.addWithValue("b", ["c"], 0);
    console.dir(g, { depth: null });

    console.log(g.lastNode());

    console.log(g.display());

    console.dir(g.resolve(), { depth: null });

    // Cycle display: No
    // g.add("c");
    // console.log(g.displayCycles());

    // Cycle display: Yes
    g.add("c", ["a"]);
    console.log(g.displayCycles());
}

function showOrderedDepMap() {
    const m = new OrderedDepMap();

    m.set("a", ['b', 'c', 'd']);
    m.set("a", ['b1', 'c1', 'd1']);
    console.log(m);

    m.add("a", ["e", "f"]);
    m.add("a", ["f", "g"]);
    console.log(m);

    console.log(m.get("a"));
    console.log(m.get("b"));

    m.set("c", ["c1", "c2", "c3"]);
    m.add("c", ["c3", "c4", "c5"]);
    m.set("d", ["d1", "d2", "d3"]);
    m.add("d", ["d4"]);
    console.log(m);

    m.delete("a");
    console.log(m);

    m.applyDiff("d", ["d5", "d1", "d2"])
    console.log(m);
}

(() => {
    console.log("\n-- Dep Graph >>\n");
    showDepGraph();

    console.log("\n-- Ordered Dep Map >>\n");
    showOrderedDepMap();
})();
