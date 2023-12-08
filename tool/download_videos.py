from pytube import YouTube
import sys

if __name__ == '__main__':
  streams = YouTube(sys.argv[1]).streams

  kwargs = {}
  kwargs['mime_type'] = sys.argv[2] if len(sys.argv) > 2 else 'video/mp4'
  if len(sys.argv) > 3:
    kwargs['res'] = sys.argv[3]
  stream = streams.filter(**kwargs)

  if not stream:
    print('No matching stream found.')
  else:
    stream[0].download()