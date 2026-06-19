import { Injectable, Logger } from '@nestjs/common';

interface DailyRoomResponse {
  name: string;
  url: string;
}

interface DailyTokenResponse {
  token: string;
}

@Injectable()
export class VideoService {
  private readonly logger = new Logger(VideoService.name);
  private readonly apiKey = process.env.DAILY_API_KEY;
  private readonly domain = process.env.DAILY_DOMAIN;

  isConfigured(): boolean {
    return !!this.apiKey;
  }

  async createRoom(roomName: string): Promise<{ roomName: string; roomUrl: string }> {
    if (!this.apiKey) {
      const fallbackUrl = this.buildFallbackRoomUrl(roomName);
      this.logger.warn('DAILY_API_KEY not set; using fallback room URL');
      return { roomName, roomUrl: fallbackUrl };
    }

    const response = await fetch('https://api.daily.co/v1/rooms', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: roomName,
        privacy: 'private',
        properties: {
          exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24,
          enable_chat: true,
          enable_screenshare: true,
          start_video_off: false,
          start_audio_off: false,
        },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      if (response.status === 400 && errorText.includes('already exists')) {
        return {
          roomName,
          roomUrl: this.buildRoomUrl(roomName),
        };
      }
      throw new Error(`Failed to create Daily room: ${errorText}`);
    }

    const data = (await response.json()) as DailyRoomResponse;
    return {
      roomName: data.name,
      roomUrl: data.url,
    };
  }

  async createMeetingToken(
    roomName: string,
    userName: string,
    isOwner: boolean,
  ): Promise<{ token: string; expiresAt: Date }> {
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000);

    if (!this.apiKey) {
      return {
        token: `dev_${roomName}_${Date.now()}`,
        expiresAt,
      };
    }

    const response = await fetch('https://api.daily.co/v1/meeting-tokens', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        properties: {
          room_name: roomName,
          user_name: userName,
          is_owner: isOwner,
          exp: Math.floor(expiresAt.getTime() / 1000),
        },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Failed to create meeting token: ${errorText}`);
    }

    const data = (await response.json()) as DailyTokenResponse;
    return { token: data.token, expiresAt };
  }

  buildJoinUrl(roomUrl: string, token: string): string {
    const separator = roomUrl.includes('?') ? '&' : '?';
    return `${roomUrl}${separator}t=${encodeURIComponent(token)}`;
  }

  private buildRoomUrl(roomName: string): string {
    if (this.domain) {
      return `https://${this.domain}.daily.co/${roomName}`;
    }
    return `https://homedx.daily.co/${roomName}`;
  }

  private buildFallbackRoomUrl(roomName: string): string {
    return this.buildRoomUrl(roomName);
  }
}
