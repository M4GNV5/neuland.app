import API from '../backend/authenticated-api'
import { formatISODate } from '../date-utils'
import roomDistances from '../../data/room-distances.json'

const IGNORE_GAPS = 15

export const BUILDINGS_ALL = 'Alle'
export const DURATION_PRESET = '01:00'

/**
 * Adds minutes to a date object.
 * @param {Date} date
 * @param {number} minutes
 * @returns {Date}
 */
function addMinutes (date, minutes) {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    date.getHours(),
    date.getMinutes() + minutes,
    date.getSeconds(),
    date.getMilliseconds()
  )
}

/**
 * Returns the earlier of two dates.
 * @param {Date} a
 * @param {Date} b
 * @returns {Date}
 */
function minDate (a, b) {
  return a < b ? a : b
}

/**
 * Returns the later of two dates.
 * @param {Date} a
 * @param {Date} b
 * @returns {Date}
 */
function maxDate (a, b) {
  return a > b ? a : b
}

/**
 * Checks whether a room is in a certain building.
 * @param {string} room Room name (e.g. `G215`)
 * @param {string} building Building name (e.g. `G`)
 * @returns {boolean}
 */
function isInBuilding (room, building) {
  return new RegExp(`${building}\\d+`, 'i').test(room)
}

/**
 * Converts the room plan for easier processing.
 * @param rooms rooms array as described in thi-rest-api.md
 * @param {Date} date Date to filter for
 * @returns {object}
 */
export function getRoomOpenings (rooms, date) {
  date = formatISODate(date)
  const openings = {}
  // get todays rooms
  rooms.filter(room => room.datum === date)
    // flatten room types
    .flatMap(room => room.rtypes)
    // flatten time slots
    .flatMap(rtype =>
      Object.values(rtype.stunden)
        .map(stunde => ({
          type: rtype.raumtyp,
          ...stunde
        }))
    )
    // flatten room list
    .flatMap(stunde =>
      stunde.raeume.split(', ')
        .map(room => ({
          room,
          type: stunde.type,
          from: new Date(date + 'T' + stunde.von),
          until: new Date(date + 'T' + stunde.bis)
        }))
    )
    // iterate over every room
    .forEach(({ room, type, from, until }) => {
      // initialize room
      const roomOpenings = openings[room] = openings[room] || []
      // find overlapping opening
      // ignore gaps of up to IGNORE_GAPS minutes since the time slots don't line up perfectly
      const opening = roomOpenings.find(opening =>
        from <= addMinutes(opening.until, IGNORE_GAPS) &&
        until >= addMinutes(opening.from, -IGNORE_GAPS)
      )
      if (opening) {
        // extend existing opening
        opening.from = minDate(from, opening.from)
        opening.until = maxDate(until, opening.until)
      } else {
        // create new opening
        roomOpenings.push({ type, from, until })
      }
    })
  return openings
}

/**
 * Get a suitable preset for the time selector.
 * If outside the opening hours, this will skip to the time the university opens.
 * @returns {Date}
 */
export function getNextValidDate () {
  const startDate = new Date()

  if (startDate.getDay() === 0 || startDate.getHours() > 20) { // sunday or after 9pm
    startDate.setDate(startDate.getDate() + 1)
    startDate.setHours(8)
    startDate.setMinutes(15)
  } else if (startDate.getHours() < 8) { // before 6am
    startDate.setHours(8)
    startDate.setMinutes(15)
  }

  return startDate
}

/**
 * Filters suitable room openings.
 * @param {string} date Start date as an ISO string
 * @param {string} time Start time
 * @param {string} [building] Building name
 * @param {string} [duration] Minimum opening duration
 * @returns {object[]}
 */
export async function filterRooms (date, time, building = BUILDINGS_ALL, duration = DURATION_PRESET) {
  const beginDate = new Date(date + 'T' + time)

  const [durationHours, durationMinutes] = duration.split(':').map(x => parseInt(x, 10))
  const endDate = new Date(
    beginDate.getFullYear(),
    beginDate.getMonth(),
    beginDate.getDate(),
    beginDate.getHours() + durationHours,
    beginDate.getMinutes() + durationMinutes,
    beginDate.getSeconds(),
    beginDate.getMilliseconds()
  )

  return searchRooms(beginDate, endDate, building)
}

/**
 * Filters suitable room openings.
 * @param {Date} beginDate Start date as Date object
 * @param {Date} endDate End date as Date object
 * @param {string} [building] Building name (e.g. `G`), defaults to all buildings
 * @returns {object[]}
 */
export async function searchRooms (beginDate, endDate, building = BUILDINGS_ALL) {
  const data = await API.getFreeRooms(beginDate)

  const openings = getRoomOpenings(data.rooms, beginDate)
  return Object.keys(openings)
    .flatMap(room =>
      openings[room].map(opening => ({
        room,
        type: opening.type,
        from: opening.from,
        until: opening.until
      }))
    )
    .filter(opening =>
      (building === BUILDINGS_ALL || isInBuilding(opening.room.toLowerCase(), building)) &&
      beginDate >= opening.from &&
      endDate <= opening.until
    )
    .sort((a, b) => a.room.localeCompare(b.room))
}

/**
 * Finds rooms that are close to the given room and are available for the given time.
 * @param {string} room Room name (e.g. `G215`)
 * @param {Date} startDate Start date as Date object
 * @param {Date} endDate End date as Date object
 * @returns {Array}
 **/
export async function findSuggestedRooms (room, startDate, endDate) {
  let rooms = await searchRooms(startDate, endDate)

  // hide Neuburg buildings if next lecture is not in Neuburg
  rooms = rooms.filter(x => x.room.includes('N') === room.includes('N'))

  // get distances to other rooms
  const distances = getRoomDistances(room)

  // sort by distance (floors are ignored)
  rooms = rooms.sort((a, b) => {
    return (distances[a?.room] ?? Infinity) - (distances[b?.room] ?? Infinity)
  })

  return rooms
}

/**
 * Returns the distance to other rooms from the given room.
 * @param {string} room Room name (e.g. `G215`)
 * @returns {object}
 **/
export function getRoomDistances (room) {
  if (!room) {
    return {}
  }

  return roomDistances[room.toUpperCase()] || {}
}
