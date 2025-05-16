<template>
    <ion-page>
        <ion-header>
            <ion-toolbar>
                <ion-title>Scanning</ion-title>
                <ion-buttons slot="end">
                    <ion-button @click="closeModal">
                        <ion-icon :icon="close"></ion-icon>
                    </ion-button>
                </ion-buttons>
            </ion-toolbar>
        </ion-header>

        <ion-content>
            <div class="square" ref="squareElement"></div>
            <ion-fab
                v-if="viewState.isTorchAvailable"
                slot="fixed"
                horizontal="end"
                vertical="bottom">
                <ion-fab-button @click="toggleTorch">
                    <ion-icon :icon="flashlight"></ion-icon>
                </ion-fab-button>
            </ion-fab>
        </ion-content>
    </ion-page>
</template>

<style scoped>
ion-content {
    --background: transparent;
}

.square {
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    border-radius: 16px;
    width: 200px;
    height: 200px;
    border: 6px solid white;
    box-shadow: 0 0 0 4000px rgba(0, 0, 0, 0.3);
}
</style>

<script setup lang="ts">
import { ref, reactive, onBeforeMount, onMounted, onUnmounted } from 'vue';
import {
    IonPage, IonHeader, IonToolbar, IonTitle,
    IonButtons, IonButton,
    IonContent,
    IonFab, IonFabButton, IonIcon,
} from '@ionic/vue';
import {
    close,
    flashlight
} from 'ionicons/icons';
import {
    Barcode,
    BarcodeFormat,
    BarcodeScanner,
    LensFacing,
    StartScanOptions
} from '@capacitor-mlkit/barcode-scanning';
import DialogService from '@/services/dialog/dialog';

// props
const props = withDefaults(defineProps<{
    formats: BarcodeFormat[],
    lensFacing: LensFacing,
}>(), {
    formats: () => [BarcodeFormat.QrCode],
    lensFacing: LensFacing.Back,
});

// states
const squareElement = ref<HTMLDivElement>();

const viewState = reactive({
    isTorchAvailable: false
});

// lifecycle
onBeforeMount(() => {
    BarcodeScanner.isTorchAvailable().then(result => {
        viewState.isTorchAvailable = result.available;
    });
});

onMounted(() => {
    setTimeout(() => {
        startScan();
    }, 250);
});

onUnmounted(() => {
    stopScan();
});

// handlers
const closeModal = async (barcode?: Barcode): Promise<void> => {
    // singleton?
    const dialogService = new DialogService();

    dialogService.dismissModal({
        barcode: barcode
    });
}

const toggleTorch = async (): Promise<void> => {
    await BarcodeScanner.toggleTorch();
}

const startScan = async () => {
    document.querySelector('body')?.classList.add('barcode-scanner-active');

    const options: StartScanOptions = {
        formats: props.formats,
        lensFacing: props.lensFacing,
    };

    const squareElementBoundingClientRect = squareElement.value?.getBoundingClientRect();

    const scaledRect = squareElementBoundingClientRect
        ? {
            left  : squareElementBoundingClientRect.left * window.devicePixelRatio,
            right : squareElementBoundingClientRect.right * window.devicePixelRatio,
            top   : squareElementBoundingClientRect.top * window.devicePixelRatio,
            bottom: squareElementBoundingClientRect.bottom * window.devicePixelRatio,
            width : squareElementBoundingClientRect.width * window.devicePixelRatio,
            height: squareElementBoundingClientRect.height * window.devicePixelRatio,
        }
        : undefined;

    const detectionCornerPoints = scaledRect
        ? [
            [scaledRect.left, scaledRect.top],
            [scaledRect.left + scaledRect.width, scaledRect.top],
            [scaledRect.left + scaledRect.width, scaledRect.top + scaledRect.height],
            [scaledRect.left, scaledRect.top + scaledRect.height],
        ]
        : undefined;

    const listener = await BarcodeScanner.addListener('barcodeScanned', async result => {
        const cornerPoints = result.barcode.cornerPoints;

        if (detectionCornerPoints && cornerPoints) {
            if (
                detectionCornerPoints[0][0] > cornerPoints[0][0] ||
                detectionCornerPoints[0][1] > cornerPoints[0][1] ||
                detectionCornerPoints[1][0] < cornerPoints[1][0] ||
                detectionCornerPoints[1][1] > cornerPoints[1][1] ||
                detectionCornerPoints[2][0] < cornerPoints[2][0] ||
                detectionCornerPoints[2][1] < cornerPoints[2][1] ||
                detectionCornerPoints[3][0] > cornerPoints[3][0] ||
                detectionCornerPoints[3][1] < cornerPoints[3][1]
            ) {
                return;
            }
        }

        await listener.remove();

        closeModal(result.barcode);
    });

    await BarcodeScanner.startScan(options);
}

const stopScan = async (): Promise<void>  => {
    document.querySelector('body')?.classList.remove('barcode-scanner-active');

    await BarcodeScanner.stopScan();
}
</script>
