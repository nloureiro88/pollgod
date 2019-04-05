//= require data-confirm-modal

import "bootstrap";

// Flatpickr setup
import flatpickr from 'flatpickr';

const currentDate = new Date();
const year = currentDate.getFullYear();
const month = currentDate.getMonth() + 1;
const day = currentDate.getDate();

flatpickr('.date-picker', {
 altInput: true,
 time_24hr: true,
 dateFormat: 'Y-m-d',
 MaxDate: `${year}-${month}-${day}`
});

// Tooltips

function isTouchDevice(){
    return true == ("ontouchstart" in window || window.DocumentTouch && document instanceof DocumentTouch);
};

if(isTouchDevice()===false) {
  $('[data-toggle="tooltip"]').tooltip({ trigger: "hover" });
  $('[data-toggle="tooltip-bottom"]').tooltip({ trigger: "hover" });
};

$(document).ready(function(){
    $('[data-toggle="tooltip-all"]').tooltip(
      {container:'body', trigger: 'hover', placement:"top"}
    );
  });

// Go up arrow

$("a[href='#go-top']").click(function() {
  $("html, body").animate({ scrollTop: 0 }, "slow");
  return false;
});

// Mobile navbar collapsing


// Function to reset all cards flipped

const resetCards = () => {
  const allCardsFronts = document.querySelectorAll('.poll-card-front');
  allCardsFronts.forEach(card => card.classList.remove("unflipped"));
  const allCardsBacks = document.querySelectorAll('.poll-card-back');
  allCardsBacks.forEach(card => card.classList.add("unflipped"));
  const allCardsStats = document.querySelectorAll('.poll-card-stats');
  allCardsStats.forEach(card => card.classList.add("unflipped"));
};

// Function to flip selected card

const flipCard = (id) => {
  const cardFront = document.querySelector(`#poll-card-front-${id}`);
  const cardBack = document.querySelector(`#poll-card-back-${id}`);
  const cardStats = document.querySelector(`#poll-card-stats-${id}`);
  setTimeout(function() {
    cardFront.classList.add("unflipped");
    if (cardFront.dataset.answered === 'false') {
      cardBack.classList.remove("unflipped");
    } else {
      cardStats.classList.remove("unflipped");
    }
  }, (400));
};

// Add event for showing the poll answer options

const pollButtons = document.querySelectorAll('.answer-button')

pollButtons.forEach((button) => {
  button.addEventListener("click", (event) => {
    resetCards()
    const pollId = event.currentTarget.dataset.poll;
    flipCard(pollId)
  });
});

// Add event for going back to the poll's first page

const backArrows = document.querySelectorAll('.go-back')

backArrows.forEach((arrow) => {
  arrow.addEventListener("click", (event) => {

    // Flip clicked card
    const pollId = event.currentTarget.dataset.poll;
    const cardFront = document.querySelector(`#poll-card-front-${pollId}`);
    const cardBack = document.querySelector(`#poll-card-back-${pollId}`);
    const cardStats = document.querySelector(`#poll-card-stats-${pollId}`);
    cardFront.classList.remove("unflipped");
    cardBack.classList.add("unflipped");
    cardStats.classList.add("unflipped");
  });
});

// Add event to poll answer options in order to show submit options

const answerOptions = document.querySelectorAll('.answer-option input')

answerOptions.forEach((option) => {
  option.addEventListener("click", (event) => {

    const pollId = event.currentTarget.dataset.poll;
    const answerButtons = document.querySelector(`#answer-bottom-${pollId}`);
    answerButtons.classList.remove("hidden");

  });
});

// Add event to poll answer submit button to: i) change answer status on html; ii) show results

const answerButton = document.querySelectorAll('.btn-send')

answerButton.forEach((button) => {
  button.addEventListener("click", (event) => {
    const pollId = event.currentTarget.dataset.poll;

    const cardFront = document.querySelector(`#poll-card-front-${pollId}`);
    cardFront.dataset.answered = 'true'

    const cardBack = document.querySelector(`#poll-card-back-${pollId}`);
    const cardStats = document.querySelector(`#poll-card-stats-${pollId}`);
    cardBack.classList.add("unflipped");
    cardStats.classList.remove("unflipped");
  });
});
