import React from 'react';
import { createRoot } from 'react-dom/client';
import AppStandalone from './AppStandalone';
import { BrowserRouter } from 'react-router-dom';

const container = document.getElementById('root');
if (container) {
  const root = createRoot(container);
  root.render(
    <BrowserRouter>
      <AppStandalone />
    </BrowserRouter>
  );
}
