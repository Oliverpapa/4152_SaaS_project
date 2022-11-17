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

class ScheduleGroup {
  constructor(oneDaySchedule, canvas, day) {
    this.attractions = Object.entries(oneDaySchedule).map(([timeStr, attraction]) => {
      let time = moment(timeStr, ["HH:mm:ss"])
      return this.makeScheduleBlock(attraction, time, canvas)
    })
    this.canvas = canvas
    this.day = day
    this.attractions.forEach((attraction) => attraction.group = this)
  }

  refreshScheduleUI() {
    this.columnSolve(this.attractions.filter(attraction => {
      return this.countConflict(this.attractions, attraction) > 1
    }))
    this.columnSolve(this.attractions.filter(attraction => {
      return this.countConflict(this.attractions, attraction) <= 1
    }))
    updateMap(this.day, location_info, this.sortedNamesByStartingTime());
  }
  onclickAddAttraction(element) {
    let button = $(element)
    let dropdownMenu = button.siblings('.dropdown-menu')

    dropdownMenu.empty()

    let existingAttractionIDs = groups.flatMap(group => group.attractions)
                                      .map(scheduledAttraction => scheduledAttraction.attraction.id)
    
    let selectableAttractions = allAttractions.filter(attraction => !existingAttractionIDs.includes(attraction.id))

    console.log(existingAttractionIDs, selectableAttractions)

    selectableAttractions.forEach(attraction => {
      $('<a/>', {
        text: attraction.name,
        class: 'dropdown-item',
        href: "#",
        click: () => this.addAttraction(attraction)
      }).appendTo(dropdownMenu)
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

  generateScheduleBlock() {
    let baseID = this.attraction.name.replaceAll(' ', '-')
    
    let block = $('<div></div>', {
      class: 'schedule-block',
      text: this.attraction.name,
      id: baseID + '-main-body'
    }).appendTo(this.canvas.parent())

    // add a close botton to the bolck
    let closeBtn = $('<button></button>', {
      class: 'close',
      text: 'x',
      id: baseID + '-close',
      click: () => this.remove(this)
    }).appendTo(block)

    // add a detail link to the bolck
    let detailLink = $('<a></a>', {
      text: 'detail',
      color: 'white',
      href: "https://www.google.com/maps/search/"+this.attraction.name+", "+this.attraction.state
    }).appendTo(block)

    // let deleteButton = $('<button/>', {
    //   text: 'delete',
    //   class: 'close-button',
    //   click: () => this.remove()
    // }).appendTo(block)

    this.block = block
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
    console.log("newScheduledTime, newDuration =", this.scheduledTime.format('HH:mm'), this.scheduledDuration.asHours())

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
    console.log(this.group.sortedNamesByStartingTime())
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
    console.log(region)

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

  for (let day = 0; day < plan.length; ++day) {
    let canvas = $(`.schedule-canvas:eq(${day})`)
    drawCanvas(canvas)

    let group = new ScheduleGroup(plan[day], canvas, day)
    group.refreshScheduleUI()

    groups.push(group)
  }

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