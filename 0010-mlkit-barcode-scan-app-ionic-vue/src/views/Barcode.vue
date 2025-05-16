<template>
    <ion-page>
        <ion-header :translucent="true">
            <ion-toolbar>
                <ion-buttons slot="start">
                    <ion-menu-button color="primary"></ion-menu-button>
                </ion-buttons>
                <ion-title>Barcode</ion-title>
            </ion-toolbar>
        </ion-header>

        <ion-content :fullscreen="true">
            <ion-header collapse="condense">
                <ion-toolbar>
                    <ion-title size="large">Barcode</ion-title>
                </ion-toolbar>
            </ion-header>
            <div class="container">
                <ion-card>
                    <ion-card-header>
                        <ion-card-title>Scan Area</ion-card-title>
                    </ion-card-header>
                    <ion-card-content>
                        <ion-grid>
                            <ion-row>
                                <ion-col>
                                    <ion-button expand="block" @click="startScanBuildIn">
                                        <ion-icon slot="start" :icon="cameraOutline"></ion-icon>
                                        Scan (Build In)
                                    </ion-button>
                                </ion-col>
                                <ion-col>
                                    <ion-button expand="block" @click="startScanCustom">
                                        <ion-icon slot="start" :icon="cameraOutline"></ion-icon>
                                        Scan (Custom)
                                    </ion-button>
                                </ion-col>
                            </ion-row>
                        </ion-grid>
                    </ion-card-content>
                </ion-card>

                <ion-card>
                    <ion-card-header>
                        <ion-card-title>Scan Result</ion-card-title>
                    </ion-card-header>
                    <ion-card-content>
                        <ion-note color="medium" v-if="viewState.results.length <= 0" class="note">
                            No scan records, Please scan first.
                        </ion-note>
                        <ion-list lines="full" v-else>
                            <ion-item v-for="result in viewState.results">
                                <ion-label>{{ result.rawValue }} - {{ result.format }}:{{ result.valueType }}</ion-label>
                            </ion-item>
                        </ion-list>
                    </ion-card-content>
                </ion-card>
            </div>
        </ion-content>
    </ion-page>
</template>

<style scoped>
.container {
    padding: 15px 25px 10px 25px;
}

.note {
    text-align: center;
    display: block;
}
</style>

<script setup lang="ts">
import { reactive } from 'vue';
import {
    IonPage, IonHeader,
    IonToolbar, IonButtons, IonMenuButton, IonTitle, IonContent,
    IonCard, IonCardHeader, IonCardTitle, IonCardContent,
    IonGrid, IonRow, IonCol,
    IonButton, IonIcon, IonNote,
    IonList, IonItem, IonLabel,
} from '@ionic/vue';
import {
    cameraOutline
} from 'ionicons/icons';
import {
    Barcode,
    BarcodeScanner,
    BarcodeFormat,
    LensFacing
} from '@capacitor-mlkit/barcode-scanning';
import DialogService from '@/services/dialog/dialog';
import BarcodeScanningModal from '@/components/BarcodeScanningModal.vue';

// states
const viewState = reactive<{
    results: Barcode[]
}>({
    results: [],
});

// handlers
/*
// single barcode case
const startScan = async () => {
    return new Promise(async resolve => {
        document.querySelector('body')?.classList.add('barcode-scanner-active');

        const listener = await BarcodeScanner.addListener('barcodeScanned', async result => {
            await listener.remove();

            document.querySelector('body')?.classList.remove('barcode-scanner-active');

            await BarcodeScanner.stopScan();

            viewState.results.push(result.barcode);

            resolve(result.barcode);
        });

        await BarcodeScanner.startScan();
    });
};
*/

const startScanBuildIn = async () => {
    const { barcodes } = await BarcodeScanner.scan({
        formats: [BarcodeFormat.QrCode],
    });

    viewState.results = [...viewState.results, ...barcodes];

    return barcodes;
};

const startScanCustom = async () => {
    // singleton?
    const dialogService = new DialogService();

    const modal = await dialogService.showModal({
        component: BarcodeScanningModal,
        cssClass: 'barcode-scanner-modal',
        showBackdrop: false,
        componentProps: {
            formats: [BarcodeFormat.QrCode, BarcodeFormat.Codabar],
            lensFacing: LensFacing.Back
        }
    });

    modal.onDidDismiss().then(result => {
        const barcode: Barcode | undefined = result.data?.barcode;

        if (barcode) {
            viewState.results.push(barcode);
        }
    });
}
</script>
