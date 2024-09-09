export const csrfToken = () => {
  return document.querySelector("meta[name='csrf-token']")?.getAttribute('content') || '';
}
