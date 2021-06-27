import 'dart:io';

const String EMPTY_STRING = '';
const String SPACE_STRING = ' ';
const String YOURU_V2 = 'YouRu v2';
const String RECENT = 'Recent';
const String SEARCH = 'Search';
const String DOWNLOAD = 'Download';
const String SEARCH_HINT = 'Search like you\'re on Youtube😎';
const String YOURU = 'YouRu';
const String ARE_YOU_SURE = 'Are you sure?';
const String ZERO = '0';
const String COLAN = ':';
const String FORWARD_SLASH = '/';
const String RELATED_VIDEOS = 'Related videos';
const String SONG_DETAILS_TEXT = 'Song details will be displayed here🤪';
const String PNGEXTNSN = '.png';
const String MP3EXTNSN = '.mp3';
const String CUSTOM_SEPERATOR = '---';
const String DOWNLOAD_FAILED = 'Download failed🤦‍♂️';
const String STARTING_SONG = 'Starting, Please wait😛';
const String AUDIO = 'audio';
const String DOTTHUMB = '.thumb';
const String FAILED_VIDEO_MSG =
    'Youtube is strict, it\'s diffcult to fetch video sometimes🤷‍♂️\nAnyway, you can play it as audio🎶';
const String RETRY = 'Retry';
const String SOMETHING_WRONG = 'Something went wrong🤦‍♂️';
const String UNABLE_TO_LOAD = 'Unable to load audio🤦‍♂️';
const String SHARE = 'Share';
const String FETCHING_WAIT = 'Fetching details, please wait😛';
const String DOWNLOAD_1_SONG = 'You can download 1 song at a time';
const String CREATE = 'CREATE';
const String CREATE_NEW_PLAYLIST = 'Create new Playlist ...';
const String ADD_TO_PLAYLIST = 'Add to Playlist';
const String PLAYLIST_STARTING = 'Starting playlist, please wait😛';
const String ADDED_TO = 'Added to';
const String DELETE = 'DELETE';
const String CANCEL = 'CANCEL';
const String SETTINGS = 'SETTINGS';

const String SPRECENT_SEARCH = 'recentSearch';
const String SPLAST_FILE = 'lastFile';
const String SPLAST_PLAYED = 'lastPlayed';
const String SPRECENTLY_PLAYED = 'recntlyPlayed';
const String SPPLAY_LIST = 'myPlayList';

String getMusicPath(String directory) =>
    '$directory${Platform.pathSeparator}${YOURU.toLowerCase()}${Platform.pathSeparator}$AUDIO${Platform.pathSeparator}';
String getThumbPath(String directory) =>
    '$directory${Platform.pathSeparator}${YOURU.toLowerCase()}${Platform.pathSeparator}$DOTTHUMB${Platform.pathSeparator}';

//Settings
const String SFORCEMUSICSEARCH = 'SFORCEMUSICSEARCH';
const String SFORCEMUSICRELATED = 'SFORCEMUSICRELATED';
const String SPAUSEONCALL = 'SPAUSEONCALL';
const String SPLAYVIDEOONBACKGROUND = 'SPLAYVIDEOONBACKGROUND';
const String SLOOPVIDEO = 'SLOOPVIDEO';
const String SSHOWRELATED = 'SSHOWRELATED';
