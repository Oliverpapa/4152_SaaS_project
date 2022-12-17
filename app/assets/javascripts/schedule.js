window['moment-range'].extendMoment(moment)

const scheduleHeight = 800
const startingHour = 8, endingHour = 24
const startingTime = moment({ hour: startingHour })
const hourPerBlock = 0.5
const blockHeight = scheduleHeight / ((endingHour - startingHour) / hourPerBlock)
const blockOffset = 60

function durationToHeight(duration) {
  return duration.asHours() / hourPerBlock * blockHeight
}
function heightToDuration(height) {
  return moment.duration(height / blockHeight * hourPerBlock, 'hours')
}
function timediffToHeight(timediff) {
  return durationToHeight(moment.duration(timediff))
}
function timeToHeight(time) {
  return timediffToHeight(time.diff(startingTime))
}
function heightToTime(height) {
  return moment(startingTime).add(moment.duration(height / blockHeight * hourPerBlock, 'hours'))
}
function roundToBlockGrid(x) {
  return Math.round(x / blockHeight) * blockHeight
}


function encodeDictToString(dict) {
  return JSON.stringify(dict)
}

function decodeStringToDict(str) {
  return JSON.parse(str)
}

function setCookie(cname, cvalue, exdays) {
  const d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  let expires = "expires="+d.toUTCString();
  document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/customize/" + suggestion_type;
}


function getCookie(cname) {
  let name = cname + "=";
  let ca = document.cookie.split(';');
  for(let i = 0; i < ca.length; i++) {
    let c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return "";
}


function updatePlanInCookie() {
  let dict = getCurrentPlanToDict()
  setCookie('plan', encodeDictToString(dict), 365)
}

function loadPlanFromCookie() {
  return decodeStringToDict(getCookie('plan'))
}

// export function getCurrentPlanToDict() {
//   let dict = groups.map((scheduleGroup) => scheduleGroup.toRawPlan())
//   return dict
// }

function getCurrentPlanToDict() {
  let dict = groups.map((scheduleGroup) => scheduleGroup.toRawPlan())
  return dict
}

class ScheduleGroup {
  constructor(oneDaySchedule, canvas, dropdown, day) {
    this.attractions = Object.entries(oneDaySchedule).map(([timeStr, attraction]) => {
      let time = moment(timeStr, ["HH:mm:ss"])
      return this.makeScheduleBlock(attraction, time, canvas)
    })
    this.canvas = canvas
    this.dropdown = dropdown
    console.log(this.dropdown.parent())
    this.dropdown.parent().on('show.bs.dropdown', () => this.refreshAddableAttractions())
    this.day = day
    this.attractions.forEach((scheduledAttraction) => scheduledAttraction.group = this)
  }

  toRawPlan() {
    let rawPlan = {}
    this.attractions.forEach((scheduledAttraction) => {
      scheduledAttraction.attraction.recommended_time = scheduledAttraction.scheduledDuration.asMinutes()
      rawPlan[scheduledAttraction.scheduledTime.format("HH:mm:ss")] = scheduledAttraction.attraction
    })
    return rawPlan
  }

  refreshScheduleUI() {
    this.columnSolve(this.attractions.filter(attraction => {
      return this.countConflict(this.attractions, attraction) > 1
    }))
    this.columnSolve(this.attractions.filter(attraction => {
      return this.countConflict(this.attractions, attraction) <= 1
    }))
    updateMap(this.day, location_info, this.sortedNamesByStartingTime());
    updatePlanInCookie()
  }
  refreshAddableAttractions() {
    let dropdownMenu = this.dropdown.siblings('.dropdown-menu')

    dropdownMenu.empty()

    let existingAttractionIDs = groups.flatMap(group => group.attractions)
                                      .map(scheduledAttraction => scheduledAttraction.attraction.id)

    let selectableAttractions = allAttractions.filter(attraction => !existingAttractionIDs.includes(attraction.id))

    // console.log(existingAttractionIDs, selectableAttractions)

    selectableAttractions.forEach(attraction => {
      $('<li/>').append(
        $('<a/>', {
          text: attraction.name,
          class: 'dropdown-item',
          href: '#' + dropdownMenu.closest('.one-day-schedule').prop('id'),
          click: () => {
            this.addAttraction(attraction)
          }
        })
      ).appendTo(dropdownMenu)
    })

  }
  addAttraction(attraction) {
    let time = timeFromDBStr(attraction.open_time)
    let scheduledAttraction = this.makeScheduleBlock(attraction, time, this.canvas)

    this.attractions.push(scheduledAttraction)
    this.refreshScheduleUI()
  }
  remove(scheduledAttraction) {
    this.attractions.splice(this.attractions.indexOf(scheduledAttraction), 1)
    this.refreshScheduleUI()
  }
  sortedNamesByStartingTime() {
    return this.attractions
      .concat()
      .sort((a, b) => a.scheduledTime - b.scheduledTime)
      .map(scheduledAttraction => scheduledAttraction.attraction.name)
  }


  makeScheduleBlock(attraction, time, canvas) {
    let scheduledAttraction = new ScheduledAttraction(attraction, time, canvas)

    scheduledAttraction.group = this
    scheduledAttraction.initUI()

    return scheduledAttraction
  }

  countConflict(list, attraction) {
    return list.filter(item => {
      return item.getScheduleRange().overlaps(attraction.getScheduleRange())
    }).length
  }

  columnSolve(attractions) {
    let columns = []
    attractions.forEach((attraction) => {
      let column = columns.find(column => this.countConflict(column, attraction) == 0)
      if (column) {
        column.push(attraction)
      } else {
        columns.push([attraction])
      }
    })

    let width = (this.canvas.width() - blockOffset) / columns.length
    for (let i = 0; i < columns.length; i++) {
      let offset = blockOffset + i * width
      columns[i].forEach(attraction => attraction.reposition({
        left: offset,
        width: width
      }))
    }
  }
}


class ScheduledAttraction {

  constructor(attraction, time, canvas) {
    this.attraction = attraction
    this.canvas = canvas

    this.openTime = timeFromDBStr(attraction.open_time)
    this.closeTime = timeFromDBStr(attraction.close_time)
    console.log(attraction, this.openTime, this.closeTime)

    if (moment.isMoment(time))
      this.scheduledTime = time
    else
      this.scheduledTime = moment(time, ["HH:mm:ss"])
    this.scheduledDuration = moment.duration(this.attraction.recommended_time, 'minutes')
  }

  generateCard() {
    let baseID = this.attraction.name.replaceAll(' ', '-')

    let block = $('<div></div>', {
      class: 'card text-dark bg-gradient overflow-auto schedule-block',
      // text: this.attraction.name,
      id: baseID + '-main-body'
    }).appendTo(this.canvas.parent())

    let body = $('<div/>', {
      class: 'card-body'
    }).appendTo(block)

    this.block = block
    this.cardBody = body
  }

  fillAttractionInfo() {
    let baseID = this.attraction.name.replaceAll(' ', '-')

    let body = this.cardBody

    // add a close botton to the block
    let closeBtn = $('<button></button>', {
      type: 'button',
      class: 'btn-close position-absolute top-0 end-0 m-1',
      'aria-label': 'Close',
      id: baseID + '-close',
      click: () => this.remove()
    }).appendTo(body)

    let title = $('<h5/>', {
      class: 'card-title',
      text: this.attraction.name
    }).appendTo(body)

    let address = $('<h6/>', {
      class: 'card-subtitle text-muted',
      text: this.attraction.city + ', ' + this.attraction.state
    }).appendTo(body)

    let text = $('<div/>').appendTo(body)

    text.raty({
      readOnly: true,
      score: this.attraction.rating,
      path: 'https://cdnjs.cloudflare.com/ajax/libs/raty/2.9.0/images'
    })

    // add a detail link to the block
    let detailLink = $('<a></a>', {
      text: 'detail',
      color: 'white',
      href: "https://www.google.com/maps/search/"+this.attraction.name+", "+this.attraction.state
    }).appendTo(body)


  }

  generateScheduleBlock() {

    this.generateCard()
    this.fillAttractionInfo()

  }

  initUI() {
    this.generateScheduleBlock()

    this.reposition({
      left: blockOffset,
      width: this.canvas.width() - blockOffset
    })

    this.initInteraction(this.canvas)
  }
  reposition(css = {}) {
    css.top = css.top || this.calcTop()
    // css.height = css.height || this.calcHeight()

    this.block.outerHeight(css.height || this.calcHeight(), true)
    css.height = undefined
    this.block.outerWidth(css.width, true)
    css.width = undefined

    this.block.css(css)
  }
  reschedule(top, height = this.block.height()) {
    this.scheduledTime = heightToTime(top)
    this.scheduledDuration = heightToDuration(height)

    if (this.group)
      this.group.refreshScheduleUI()
    else
      this.reposition()
  }
  remove() {
    this.block.remove()
    if (this.group)
      this.group.remove(this)
  }

  calcTop() {
    return timeToHeight(this.scheduledTime)
  }
  calcHeight() {
    return durationToHeight(this.scheduledDuration)
  }

  updateElementPosition(y, height) {
    let roundedHeight = roundToBlockGrid(height)
    let roundedY = roundToBlockGrid(y)

    this.reschedule(roundedY, roundedHeight)
  }
  dragmoveListener = function (event) {
    let { x, y } = event.target.dataset
    x = (parseFloat(x) || 0) + event.dx
    y = (parseFloat(y) || this.calcTop()) + event.dy

    this.updateElementPosition(y, event.rect.height)

    Object.assign(event.target.dataset, { x, y })
  }
  resizemoveListener = function (event) {
    let { x, y } = event.target.dataset

    x = (parseFloat(x) || 0) + event.deltaRect.left
    y = (parseFloat(y) || this.calcTop()) + event.deltaRect.top

    this.updateElementPosition(y, event.rect.height)

    Object.assign(event.target.dataset, { x, y })
  }
  moveEndListener = function (event) {
    delete event.target.dataset.x
    delete event.target.dataset.y
  }

  initInteraction() {

    let region = {
      top: this.canvas.offset().top + timeToHeight(this.openTime),
      bottom: this.canvas.offset().top + timeToHeight(this.closeTime),
      left: 0,
      right: 0
    }
    console.log(this.openTime.format('HH:mm'), this.closeTime.format('HH:mm'))
    console.log(this.canvas.offset(), timeToHeight(this.openTime), timeToHeight(this.closeTime))

    let businessTimeDragConstraint =
      interact.modifiers.restrictRect({ restriction: region })

    this.block.get(0).dataset.x = 0
    this.block.get(0).dataset.y = this.calcTop()

    interact(this.block.get(0))
      .draggable({
        modifiers: [businessTimeDragConstraint],
        listeners: {
          move: this.dragmoveListener.bind(this)
        },
        lockAxis: 'y',
      })

    let businessTimeResizeConstraint =
      interact.modifiers.restrictEdges({ outer: region })
    let minDurationConstraint =
      interact.modifiers.restrictSize({
        min: { height: blockHeight }
      })

    interact(this.block.get(0))
      .resizable({
        edges: { top: true, left: false, bottom: true, right: false },
        modifiers: [
          businessTimeResizeConstraint,
          minDurationConstraint
        ],
        listeners: {
          move: this.resizemoveListener.bind(this)
        }
      })

    interact(this.block.get(0))
      .on(['resizeend', 'dragend'], this.moveEndListener.bind(this))
  }

  getScheduleRange() {
    return moment.range(this.scheduledTime, moment(this.scheduledTime).add(this.scheduledDuration))
  }
}

let groups = []

$(function () {

  if (isNewPlan == false && getCookie('plan') != '') {
    plan = loadPlanFromCookie()
    console.log(plan)
  }
  for (let day = 0; day < plan.length; ++day) {
    let canvas = $(`.schedule-canvas:eq(${day})`)
    let dropdown = $(`.dropdown-toggle:eq(${day})`)
    drawCanvas(canvas)

    let group = new ScheduleGroup(plan[day], canvas, dropdown, day)
    group.refreshScheduleUI()

    groups.push(group)
  }

  updatePlanInCookie()

})

function drawCanvas(canvas) {
  let ctx = canvas.get(0).getContext('2d')
  ctx.textBaseline = 'top'

  for (let h = startingHour, x = 0, y = 0, time = moment({ hour: 0 }); h <= endingHour; h += hourPerBlock * 2, y += blockHeight * 2) {

    time.hour(h)
    ctx.fillText(time.format('HH:mm'), x, y)
    ctx.fillRect(x, y, canvas.width(), 1)
  }
}

function timeFromDBStr(str) {
  let time = moment(str).utc()
  return moment({
    hour: time.hour(),
    minute: time.minute()
  })
}

function generatePDF() {
  var pdf = new jsPDF({
      orientation: 'p',
      unit: 'mm',
      format: 'a4',
      putOnlyUsedFonts:true
  });
  pdf.text("Your Traveling Plan:", 10, 20);

  // get current plan in dict 
  curr_plan = getCurrentPlanToDict()

  //count the y position
  let finalY = 35

  // make multiple pdf tables of contents
  for (var i = 0; i < curr_plan.length; i++) {
    var body = [];
    day_schedule = curr_plan[i]
    // convert day_schedule to a list of lists and sort by time
    day_schedule = Object.keys(day_schedule).sort().map(function(key) {
      return [key, day_schedule[key]];
    });

    // iter through day schedule
    for (var j = 0; j < day_schedule.length; j++) {
      // get the time key and the schedule
      time = day_schedule[j][0]
      schedule = day_schedule[j][1]
      // get the open and close time
      open_time = new Date(schedule["open_time"])
      open_time = open_time.getUTCHours();
      close_time = new Date(schedule["close_time"])
      close_time = close_time.getUTCHours();
      open_time = open_time + ":00"
      close_time = close_time + ":00"
      // add to the body
      body.push([time.substring(0, time.length - 3),
                schedule["name"],
                schedule["address"],
                schedule["recommended_time"],
                schedule["rating"], open_time, close_time]);
    }
    // add the day to the pdf
    pdf.text("Day " + (i + 1) + ":", 10, finalY);
    finalY += 5;
    // add the table to the pdf
    pdf.autoTable({
      head: [['Scheduled Time', 'Attraction', 'Address', 
      'Recommended Duration (mins)', 'Rating', 'Open Time', 'Close Time']],
      body: body,
      startY: finalY,
      theme: 'grid',
      styles: {overflow: 'linebreak'},
      columnStyles: {text: {columnWidth: 'wrap'}}
    });
    finalY = pdf.lastAutoTable.finalY + 15;
  }
  pdf.save('traveling_plan.pdf');
}
