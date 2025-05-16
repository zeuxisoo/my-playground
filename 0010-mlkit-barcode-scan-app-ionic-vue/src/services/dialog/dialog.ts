import { ModalOptions, modalController } from '@ionic/vue';

class DialogService {

    public async showModal(options: ModalOptions): Promise<HTMLIonModalElement> {
        const modal = await modalController.create(options);

        await modal.present();

        return modal;
    }

    public async dismissModal(data?: any): Promise<boolean> {
        return modalController.dismiss(data);
    }

}

export default DialogService;
