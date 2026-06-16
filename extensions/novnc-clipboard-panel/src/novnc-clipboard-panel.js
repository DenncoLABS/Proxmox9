(function () {
  'use strict';

  const PANEL_ID = 'dncp-panel';
  const BUTTON_ID = 'dncp-button';
  const TEXT_ID = 'dncp-text';
  const STATUS_ID = 'dncp-status';
  const TYPE_DELAY_MS = 20;

  window.DNCP_LOADED = true;

  function setStatus(message) {
    const status = document.getElementById(STATUS_ID);
    if (status) status.textContent = message;
  }

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  function findCanvas() {
    return document.querySelector('canvas') || document.getElementById('noVNC_canvas');
  }

  function sendCharToCanvas(canvas, ch) {
    const key = ch === '\n' ? 'Enter' : ch;
    const code = ch === '\n' ? 'Enter' : '';
    const eventBase = {
      key,
      code,
      bubbles: true,
      cancelable: true,
      composed: true
    };

    canvas.focus();
    canvas.dispatchEvent(new KeyboardEvent('keydown', eventBase));
    if (ch !== '\n') {
      canvas.dispatchEvent(new KeyboardEvent('keypress', eventBase));
    }
    canvas.dispatchEvent(new KeyboardEvent('keyup', eventBase));
  }

  async function sendText() {
    const textarea = document.getElementById(TEXT_ID);
    const canvas = findCanvas();

    if (!textarea || !canvas) {
      setStatus('No active noVNC canvas found. Click inside the console and try again.');
      return;
    }

    const text = textarea.value;
    if (!text) {
      setStatus('Nothing to send.');
      return;
    }

    setStatus('Sending text to console...');
    canvas.focus();

    for (const ch of text) {
      sendCharToCanvas(canvas, ch);
      await sleep(TYPE_DELAY_MS);
    }

    setStatus('Sent.');
  }

  function clearText() {
    const textarea = document.getElementById(TEXT_ID);
    if (textarea) textarea.value = '';
    setStatus('Cleared.');
  }

  function buildPanel() {
    if (document.getElementById(PANEL_ID)) return;

    const panel = document.createElement('div');
    panel.id = PANEL_ID;
    panel.hidden = true;
    panel.innerHTML = `
      <h3>Console Clipboard</h3>
      <textarea id="${TEXT_ID}" spellcheck="false" placeholder="Paste text here, then click Send to Console"></textarea>
      <div class="dncp-actions">
        <button id="dncp-send" type="button">Send to Console</button>
        <button id="dncp-clear" type="button">Clear</button>
        <button id="dncp-close" type="button">Close</button>
      </div>
      <div id="${STATUS_ID}">Ready.</div>
    `;
    document.body.appendChild(panel);

    document.getElementById('dncp-send').addEventListener('click', sendText);
    document.getElementById('dncp-clear').addEventListener('click', clearText);
    document.getElementById('dncp-close').addEventListener('click', () => {
      panel.hidden = true;
    });
  }

  function openPanel() {
    buildPanel();
    const panel = document.getElementById(PANEL_ID);
    panel.hidden = !panel.hidden;
    if (!panel.hidden) {
      const textarea = document.getElementById(TEXT_ID);
      if (textarea) textarea.focus();
    }
  }

  function findSidebarAnchor() {
    const selectors = [
      '#noVNC_control_bar .noVNC_button',
      '#noVNC_control_bar button',
      '#noVNC_control_bar div',
      '.noVNC_button',
      '[id*="settings"]',
      '[title*="Settings"]'
    ];

    for (const selector of selectors) {
      const items = Array.from(document.querySelectorAll(selector));
      if (items.length) return items;
    }

    return [];
  }

  function makeButton() {
    const button = document.createElement('div');
    button.id = BUTTON_ID;
    button.title = 'Clipboard';
    button.textContent = '📋';
    button.addEventListener('click', openPanel);
    return button;
  }

  function insertButton() {
    if (document.getElementById(BUTTON_ID)) return true;

    const button = makeButton();
    const controlBar = document.getElementById('noVNC_control_bar') || document.querySelector('.noVNC_control_bar');
    if (controlBar) {
      const controls = findSidebarAnchor();
      const gear = controls.find((el) => /settings|gear/i.test(el.id + ' ' + el.title + ' ' + el.className));
      if (gear && gear.parentNode) {
        gear.parentNode.insertBefore(button, gear);
      } else {
        controlBar.appendChild(button);
      }
      return true;
    }

    button.classList.add('dncp-fixed');
    document.body.appendChild(button);
    return true;
  }

  function boot() {
    buildPanel();

    let attempts = 0;
    const timer = setInterval(() => {
      attempts += 1;
      if (insertButton() || attempts > 40) {
        clearInterval(timer);
      }
    }, 500);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
