//= require data-confirm-modal

import "bootstrap";

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

// Go Up Arrow

$("a[href='#go-top']").click(function() {
  $("html, body").animate({ scrollTop: 0 }, "slow");
  return false;
});

// Render summary chart on card

const renderChart = (id, label_list, value_list) => {
  console.log(id, label_list, value_list)
  var Chart = require('chart.js');
  var ctx = document.getElementById(`myChart-${id}`).getContext('2d');
  var myChart = new Chart(ctx, {
      type: 'bar',
      data: {
          labels: label_list,
          datasets: [{
              label: '# of Votes',
              data: value_list,
              backgroundColor: [
                  'rgba(255, 99, 132, 0.2)',
                  'rgba(54, 162, 235, 0.2)',
                  'rgba(255, 206, 86, 0.2)',
                  'rgba(75, 192, 192, 0.2)',
                  'rgba(153, 102, 255, 0.2)',
                  'rgba(255, 159, 64, 0.2)'
              ],
              // borderColor: [
              //     'rgba(255, 99, 132, 1)',
              //     'rgba(54, 162, 235, 1)',
              //     'rgba(255, 206, 86, 1)',
              //     'rgba(75, 192, 192, 1)',
              //     'rgba(153, 102, 255, 1)',
              //     'rgba(255, 159, 64, 1)'
              // ],
              borderWidth: 0
          }]
      },
      options: {
          scales: {
              yAxes: [{
                  ticks: {
                      beginAtZero: true
                  }
              }]
          }
      }
});
}

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
  cardFront.classList.add("unflipped");
  if (cardFront.dataset.answered === 'false') {
    cardBack.classList.remove("unflipped");
  } else {
    cardStats.classList.remove("unflipped");
    // $.ajax(`/polls/${id}/results`)
    // renderChart(id, @options, @results)
  }
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
