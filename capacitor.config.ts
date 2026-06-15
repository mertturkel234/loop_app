import type { CapacitorConfig } from '@capacitor/core';

const LIVE_URL = 'https://lojistikweb-vitrin.vercel.app/';

const config: CapacitorConfig = {
  appId: 'com.loop.lojistik',
  appName: 'LOOP',
  webDir: 'www',
  server: {
    url: LIVE_URL,
    cleartext: false,
    allowNavigation: [
      'lojistikweb-vitrin.vercel.app',
      '*.vercel.app',
      'loop.com.tr',
      '*.loop.com.tr',
    ],
    errorPath: 'offline.html',
  },
  plugins: {
    SplashScreen: {
      launchShowDuration: 2500,
      launchAutoHide: true,
      backgroundColor: '#0B1220',
      androidSplashResourceName: 'splash',
      androidScaleType: 'CENTER_CROP',
      showSpinner: true,
      spinnerColor: '#3B82F6',
      splashFullScreen: true,
      splashImmersive: true,
    },
    StatusBar: {
      style: 'DARK',
      backgroundColor: '#0B1220',
    },
  },
  android: {
    allowMixedContent: false,
    backgroundColor: '#0B1220',
  },
  ios: {
    backgroundColor: '#0B1220',
    contentInset: 'automatic',
    scrollEnabled: true,
  },
};

export default config;
