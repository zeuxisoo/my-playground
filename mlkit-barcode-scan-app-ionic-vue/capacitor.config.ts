import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'im.ggd.mlkitbarcode',
  appName: 'MLKitBarCode',
  webDir: 'dist',
  server: {
    androidScheme: 'https'
  }
};

export default config;
