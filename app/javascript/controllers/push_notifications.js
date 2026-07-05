// Abonnement aux notifications push web.
// S'active sur le bouton #enable-push-btn (affiché si data-vapid-key présent).
function urlBase64ToUint8Array(base64String) {
  const padding = "=".repeat((4 - base64String.length % 4) % 4)
  const base64 = (base64String + padding).replace(/-/g, "+").replace(/_/g, "/")
  const rawData = window.atob(base64)
  return Uint8Array.from([...rawData].map((c) => c.charCodeAt(0)))
}

async function subscribeToPush(vapidKey, csrfToken) {
  const registration = await navigator.serviceWorker.register("/service-worker")
  await navigator.serviceWorker.ready

  const permission = await Notification.requestPermission()
  if (permission !== "granted") return false

  const subscription = await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: urlBase64ToUint8Array(vapidKey)
  })

  const json = subscription.toJSON()
  const response = await fetch("/push_subscriptions", {
    method: "POST",
    headers: { "Content-Type": "application/json", "X-CSRF-Token": csrfToken },
    body: JSON.stringify({
      push_subscription: {
        endpoint: json.endpoint,
        p256dh_key: json.keys.p256dh,
        auth_key: json.keys.auth
      }
    })
  })
  return response.ok
}

document.addEventListener("DOMContentLoaded", () => {
  const button = document.getElementById("enable-push-btn")
  if (!button) return
  if (!("serviceWorker" in navigator) || !("PushManager" in window)) {
    button.closest(".push-prompt")?.remove()
    return
  }
  if (Notification.permission === "granted") {
    button.closest(".push-prompt")?.remove()
    return
  }

  button.addEventListener("click", async () => {
    button.disabled = true
    try {
      const ok = await subscribeToPush(button.dataset.vapidKey, button.dataset.csrf)
      if (ok) button.closest(".push-prompt")?.remove()
      else button.disabled = false
    } catch (e) {
      console.warn("Push subscription failed:", e)
      button.disabled = false
    }
  })
})
