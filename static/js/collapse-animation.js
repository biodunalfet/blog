document.addEventListener('DOMContentLoaded', () => {
    // Get all details elements
    const allDetails = document.querySelectorAll('details');

    allDetails.forEach(details => {
        // Store the animation state
        let animationInProgress = false;

        // Handle the toggle event
        details.addEventListener('toggle', () => {
            // Get the content div inside this details element
            const content = details.querySelector('div');

            if (!content) return; // Skip if no div is found

            // Prevent multiple animations from running simultaneously
            if (animationInProgress) return;

            animationInProgress = true;

            // When animation ends, remove the animation classes
            const handleAnimationEnd = () => {
                animationInProgress = false;
                content.removeEventListener('animationend', handleAnimationEnd);
            };

            content.addEventListener('animationend', handleAnimationEnd);
        });
    });
});