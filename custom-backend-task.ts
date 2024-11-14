export async function hello(name) {
  return `Hello ${name}!`;
}

export async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}