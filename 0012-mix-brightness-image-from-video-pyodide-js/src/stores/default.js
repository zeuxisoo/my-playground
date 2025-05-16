import { writable } from 'svelte/store';

function createDefaultStore() {
    const initState = {
        selectedCount: 0,
        renderedCount: 0,
    }

    const { subscribe, set, update } = writable(initState);

    return {
        subscribe,

        setSelectedCount: value => update(state => ({
            ...state,
            selectedCount: value,
        })),

        setRenderedCount: value => update(state => ({
            ...state,
            selectedCount: value,
        })),

        increaseCount: kind => update(state => {
            if (kind === 'selected') {
                return {
                    ...state,
                    selectedCount: state.selectedCount + 1
                }
            }

            if (kind === 'rendered') {
                return {
                    ...state,
                    renderedCount: state.renderedCount + 1
                }
            }
        }),

        reset: () => set(initState),
    }
}

export default createDefaultStore();
