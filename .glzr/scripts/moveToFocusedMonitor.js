import { ContainerType, Monitor, WmClient } from 'glazewm';
import { promiseTimeout } from './helpers.functions';

const client = new WmClient();
client.onConnect(async () => {
  await run();
  await promiseTimeout(1000);
  process.exit(0);
});

async function run() {
  const { focused } = await client.queryFocused();
  if (focused.type !== ContainerType.WINDOW)
    return;

  const { monitors } = await client.queryMonitors();
  if (monitors.length === 1)
    return;

  // Find the currently focused monitor
  const focusedMonitor = monitors.find(m => m.hasFocus);
  if (!focusedMonitor)
    return;

  // Find the active workspace on the focused monitor
  const activeWorkspace = focusedMonitor.children.find(w => w.isDisplayed);
  if (!activeWorkspace)
    return;

  // Move the window to the active workspace on the focused monitor
  await client.runCommand(`move --workspace ${activeWorkspace.name}`, focused.id);
  await promiseTimeout(150);
  await client.runCommand(`focus --workspace ${activeWorkspace.name}`);
}