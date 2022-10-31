exports.handler = async (event) => {
    const min = (event.min === undefined) ? 1 : event.min
    const max = (event.max === undefined) ? 10 : event.max
    
    return Math.floor((Math.random() * max) + min)
}