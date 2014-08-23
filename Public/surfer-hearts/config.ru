
require 'surfer'
require 'middleware/Allow_Only_Roman_Uri'
require 'middleware/Squeeze_Uri_Dots'

use Allow_Only_Roman_Uri
use Squeeze_Uri_Dots

run Sinatra::Application
