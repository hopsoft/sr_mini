import { createConsumer } from '@rails/actioncable'
import { Application, Controller } from 'stimulus'
import StimulusReflex from 'stimulus_reflex'

const consumer = createConsumer()
const application = Application.start()

StimulusReflex.initialize(application, { consumer, debug: true })
