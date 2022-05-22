const CACHE_NAME = "hn-api"

self.addEventListener("install", (event) => {
    event.waitUntil(caches.open(CACHE_NAME))
})

function isCacheableApiRequest(req) {
    return (
        req.method === "GET" &&
        new URL(req.url).hostname === "hacker-news.firebaseio.com"
    )
}

self.addEventListener("fetch", (event) => {
    if (isCacheableApiRequest(event.request)) {
        return event.respondWith(
            caches.open(CACHE_NAME).then((cache) => {
                return cache.match(event.request).then((cachedResponse) => {
                    // Fetch and update cache in background
                    const networkPromise = fetch(event.request).then((res) => {
                        cache.put(event.request, res.clone())
                        return res
                    })
                    return cachedResponse || networkPromise
                })
            }),
        )
    }
})
