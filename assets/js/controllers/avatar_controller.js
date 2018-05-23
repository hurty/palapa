// Inspired by https://jsfiddle.net/u0nxLyvn/16/

import { Controller } from "stimulus"

const COLORS = "ea644f f6f3e1 a9c8bc 859c9a 454549 f28281 fbdfc7 f7d8a5 f8cc63 4b608d 7ea79f 6d9da9 ffa07a 8b7765".split(" ").map(hex => `#${hex}`)

export default class extends Controller {
  connect() {
    this.element.src = URL.createObjectURL(this.svgBlob)
  }

  disconnect() {
    URL.revokeObjectURL(this.element.src)
  }

  get svgBlob() {
    return new Blob([this.svg], { type: "image/svg+xml" })
  }

  get svg() {
    return createAvatarSVG(this.initials, this.color)
  }

  get color() {
    const codes = Array.from(this.name).map(s => s.codePointAt(0))
    const seed = codes.reduce((value, code) => value += code, this.name.length)
    return COLORS[seed % COLORS.length]
  }

  get initials() {
    return this.name.split(/\s+/).map(word => Array.from(word)[0]).join("").toLocaleUpperCase()
  }

  get name() {
    return this.element.getAttribute("alt").trim()
  }
}

function createAvatarSVG(text, color) {
  return `
    <svg width="64" height="64" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="${color}" />
      <text x="50%" y="50%"
        fill="#fff"
        text-anchor="middle"
        lengthAdjust="spacingAndGlyphs"
        dominant-baseline="central"
        font-family="-apple-system, BlinkMacSystemFont, Segoe UI, Roboto, Oxygen, Ubuntu, Cantarell, Fira Sans, Droid Sans, Helvetica Neue, sans-serif"
        font-size="26" 
        ${text.length >= 3 ? `textLength="80%"` : ""}>
        ${text}
      </text>
    </svg>
  `.trim()
}
