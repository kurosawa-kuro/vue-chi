import { ref, onMounted, onUnmounted } from 'vue'

/**
 * Composable for dropdown functionality
 * Handles opening/closing state and outside click/escape key behavior
 */
export function useDropdown() {
  const dropdownOpen = ref(false)
  const trigger = ref(null)
  const dropdown = ref(null)

  // close on click outside
  const clickHandler = ({ target }) => {
    if (!dropdownOpen.value || dropdown.value.contains(target) || trigger.value.contains(target)) return
    dropdownOpen.value = false
  }

  // close if the esc key is pressed
  const keyHandler = ({ keyCode }) => {
    if (!dropdownOpen.value || keyCode !== 27) return
    dropdownOpen.value = false
  }

  onMounted(() => {
    document.addEventListener('click', clickHandler)
    document.addEventListener('keydown', keyHandler)
  })

  onUnmounted(() => {
    document.removeEventListener('click', clickHandler)
    document.removeEventListener('keydown', keyHandler)
  })

  return {
    dropdownOpen,
    trigger,
    dropdown,
  }
}