import { Elm } from './src/Main.elm'

if ('serviceWorker' in navigator) {
    navigator.serviceWorker
        .register(new URL('./service-worker.js', import.meta.url), {
            scope: '.',
        })
        .then((registration) => {
            console.log('service worker registered', registration)
        })
}

const app = Elm.Main.init()

app.ports.scrollToComment.subscribe((id) => {
    window.requestAnimationFrame(() => {
        const node = document.querySelector(`.comment-${id}`)
        if (!overlapsViewport(node)) {
            node.scrollIntoView()
        }
    })
})

function overlapsViewport(node) {
    const rect = node.getBoundingClientRect()
    return (
        rect.top >= 0 ||
        (rect.bottom >= 0 &&
            rect.bottom <=
                (window.innerHeight || document.documentElement.clientHeight))
    )
}
