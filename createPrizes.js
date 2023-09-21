// test configuration
[
    16,  7, 38, 36,  92, 27, 52, 65, 82, 58, 64, 91,
    20, 47, 80, 46,  35, 95, 54, 74, 12,  9, 78,  4,
    81, 48, 15,  5,  96, 14, 61, 93, 68, 83,  1, 97,
     3,  6, 19, 49,  89, 56, 29, 60, 10, 51, 66, 84,
     8, 22, 98, 62,  90, 75, 76, 17, 33, 21, 86, 59,
    57, 23, 71, 87,  67, 28, 41, 50, 24, 69, 37, 70,
    88, 73, 18, 26, 100, 44, 42, 85, 25, 11, 45, 77,
    43, 40, 13, 53,  31,  2, 72, 94, 99, 79, 34, 55,
    32, 63, 30, 39
  ]
  [
    100000, 50000, 10000, 10000, 10000, 10000, 5000, 5000, 5000,
      5000,  5000,  5000,  5000,  5000,  5000, 5000, 1000, 1000,
      1000,  1000,  1000,  1000,  1000,  1000, 1000, 1000, 1000,
      1000,  1000,  1000,  1000,  1000,  1000, 1000, 1000, 1000,
       500,   500,   500,   500,   500,   500,  500,  500,  500,
       500,   500,   500,   500,   500,   500,  500,  500,  500,
       500,   500,   500,   500,   500,   500,  500,  500,  500,
       500,   500,   500,   100,   100,   100,  100,  100,  100,
       100,   100,   100,   100,   100,   100,  100,  100,  100,
       100,   100,   100,   100,   100,   100,  100,  100,  100,
       100,   100,   100,   100,   100,   100,  100,  100,  100,
       100
  ]

const { generateImages } = require("./imglib.js")
const prizes = 
[
    {
        prize: 100000, // 100000
        amount: 1,
        winners: [],
    },
    {
        prize: 50000, // 50000
        amount: 1,
        winners: [],
    },
    {
        prize: 10000,// 40000
        amount: 4,
        winners: [],
    },
    {
        prize: 5000, // 50000
        amount: 10,
        winners: [],
    },
    {
        prize: 1000, // 20000
        amount: 20,
        winners: [],
    },
    {
        prize: 500, // 15000
        amount: 30,
        winners: [],
    },
    {
        prize: 100, // 3000
        amount: 30,
        winners: [],
    },
    {
        prize: 100,  // 1000
        amount: 4,
        winners: [],
    }
]

// 279000 total prizes

function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1)); // Generate a random index between 0 and i
      [array[i], array[j]] = [array[j], array[i]]; // Swap elements at i and j
    }
  }
  
const getRandomTicketFromArrayAndRemove = (arr) => {
    const randomIndex = Math.floor(Math.random() * arr.length);
    let result = arr[randomIndex];
    arr.splice(randomIndex, 1);
    return result;
  }

const designPrize = () => {
   let ticketCount = 100;
   let ticketArray = [];
    
   for(i=1; i<ticketCount + 1; i++) {
    ticketArray.push(i)
   }

   prizes.forEach(prize => {
        // get random position from array;
        // remove that position from the array
        for(p=0; p<prize.amount; p++) {
            if(ticketArray.length > 0) {
                prize.winners.push(getRandomTicketFromArrayAndRemove(ticketArray));
            }
        }
   })

   let winArray = []

   prizes.forEach(prize => {
        prize.winners.forEach(winner => {
            // we need to get 8 numbers on the tickets

            let numbers = [];
            // first push the 3 numbers to array
            for(let i=0; i<3; i++) {
                numbers.push(prize.prize.toString());
            }
            // for the remaining 5 numbers get 5 unique other numbers
            let possibilities = [100, 100, 500, 500, 1000, 1000, 5000, 5000, 10000, 100000, 100000];
            // remove numbers we already have
            let idx = possibilities.indexOf(prize.prize);
            possibilities.splice(idx, 2);

            for(let i=0; i<5; i++) {
                let randomIndex = Math.floor(Math.random() * possibilities.length);
                numbers.push(possibilities[randomIndex].toString())
                possibilities.splice(randomIndex, 1);
            }

            shuffleArray(numbers)
            winArray.push({id: winner, prize: prize.prize, numbers})

        })
   })



   generateImages(winArray)
   // after contract deployment set the prizes to match the images
   // need to update chainlink VRF consumer!!
   let k = []
   let v = []
   winArray.forEach(val => {
    k.push(val.id), v.push(val.prize) 
    })

    console.log(k)
    console.log(v)
}

designPrize();