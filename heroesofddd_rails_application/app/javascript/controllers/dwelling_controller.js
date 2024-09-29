import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["slider", "recruitCount", "totalCost", "messageBox"]
    static values = {
        availableCreatures: Number,
        costPerTroop: Object,
        message: Object
    }

    connect() {
        console.log("Dwelling controller connected")
        this.updateRecruitCount(0)
        this.showMessageFromValue()
    }

    showMessageFromValue() {
        if (this.hasMessageValue) {
            const { type, text } = this.messageValue
            this.showMessage(text, type === 'alert')
            // Clear the message after showing it
            this.messageValue = null
        }
    }

    updateRecruitCount(count) {
        this.recruitCountTarget.textContent = count
        this.updateTotalCost(count)
    }

    updateTotalCost(count) {
        Object.entries(this.costPerTroopValue).forEach(([resource, amount]) => {
            const totalElement = this.totalCostTarget.querySelector(`#total-${resource.toLowerCase()}`)
            if (totalElement) {
                totalElement.textContent = count * amount
            }
        })
    }

    sliderChanged() {
        const count = parseInt(this.sliderTarget.value)
        this.updateRecruitCount(count)
    }

    selectAll() {
        this.sliderTarget.value = this.availableCreaturesValue
        this.updateRecruitCount(this.availableCreaturesValue)
    }

    showMessage(message, isError = false) {
        this.messageBoxTarget.textContent = message
        this.messageBoxTarget.classList.toggle('recruitment__message-box__text--error', isError)
        this.messageBoxTarget.style.display = 'block'
    }
}