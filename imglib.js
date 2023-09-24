var Jimp = require('jimp');
const fs = require('fs');
require('dotenv').config()

const generateImages = async (winArray) => {
  let promiseArray = []
  winArray.forEach(win => {
    promiseArray.push(generateImage(win))
  })

  Promise.all(promiseArray)
}

const generateImage = async (win) => {
  try {
      let item = win
      let baseTextFont = Jimp.FONT_SANS_32_WHITE
      let subTextFont = Jimp.FONT_SANS_32_WHITE;
  
      let img =  await Jimp.read(`./templates/${win.edition}.png`)
    
      let font = await Jimp.loadFont(baseTextFont)  
      let stFont = await Jimp.loadFont(subTextFont)  

      // make numbers more readable
      let numbers = {
        '100' : { written: '100', subtext: 'one-hundred'},
        '500' : { written: '500', subtext: 'five-hundred'},
        '1000' : { written: '1,000', subtext: 'one-thousand'},
        '5000' : { written: '5,000', subtext: 'five-thousand'},
        '10000' : { written: '10,000', subtext: 'ten-thousand'},
        '50000' : { written: '50,000', subtext: 'fifty-thousand'},
        '100000' : { written: '100,000', subtext: 'hundred-thousand'},
      }

      img.print(font, -19, 865,   {
        text: numbers[item.numbers[0]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  
      img.print(font, 165, 865,   {
        text: numbers[item.numbers[1]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  
      img.print(font, 351, 865,   {
        text: numbers[item.numbers[2]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  
      img.print(font, 540, 865,   {
        text: numbers[item.numbers[3]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  
      img.print(font, -19, 1040,   {
        text: numbers[item.numbers[4]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  
  
      img.print(font, 165, 1040,   {
        text: numbers[item.numbers[5]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )

      img.print(font, 351, 1040,   {
        text: numbers[item.numbers[6]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  

      img.print(font, 540, 1040,   {
        text: numbers[item.numbers[7]].written,
        alignmentX: Jimp.HORIZONTAL_ALIGN_CENTER,
        alignmentY: Jimp.VERTICAL_ALIGN_TOP
      }, 300,50 )
  
      img.resize(795, 1501)
      img.writeAsync(`tickets/${item.id}.png`);

  } catch (e) {
    throw new Error(e)
    
  } 
}

module.exports = {generateImages}