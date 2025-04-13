import fetch from 'node-fetch';
import jsdom from 'jsdom';
import { messagingApi } from '@line/bot-sdk';
import 'dotenv/config';

const sendMessage = (propertyInfoList) => {
  const { MessagingApiClient } = messagingApi;

  const client = new MessagingApiClient({
      channelAccessToken: process.env.LINE_CHANNEL_TOKEN,
  });

  const messages = propertyInfoList.map((info) => {
    return {
      type: "text",
      text: `物件名: ${info.title}\n[アクセス] \n${info.accessList.join(',')}\n\n詳細リンク\n${info.links.join('\n')}`
    }
  })

  client.pushMessage({
    to: process.env.LINE_USER_ID,
    messages: messages,
  }).then(() => {
    return {
      statusCode: 200,
      body: {
        message: "メッセージを送信しました。"
      }
    }
  }).catch((err) => {
    console.error(err);
    return {
      statusCode: 500,
      body: {
        
        error: err,
      }
    }
  });
}

const getPropertyInfoList = (elements) => {
  const baseURL = process.env.BASE_URL;

  return elements.map((item) => {
    const title = item.querySelectorAll('.cassetteitem_content-title')[0].textContent.trim();

    // ["A駅 歩5分", "B駅 歩10分"] のような形の配列
    const accessList = Array.from(item.querySelectorAll('.cassetteitem_detail-col2 div.cassetteitem_detail-text')).map(col => {
      return col.textContent.trim()
    });

    const links = Array.from(item.querySelectorAll('a.js-cassette_link_href.cassetteitem_other-linktext')).map(link => baseURL + link.href);

    return {
      title: title,
      accessList: accessList,
      links: links
    }
  })
}

export async function handler(event, context) {
  const { JSDOM } = jsdom;
  const searchURL = process.env.SEARCH_URL;

  // dom要素の取得
  const res = await fetch(searchURL);
  const html = await res.text();
  const dom = new JSDOM(html);
  const document = dom.window.document;

  // セレクターで要素取得 (Lineでメッセージを同時に送れるのが上限5なのでスライスしておく)
  const cassetteitems = Array.from(document.querySelectorAll('div.cassetteitem')).slice(0,5);

  const propertyInfoList = getPropertyInfoList(cassetteitems);

  const result = sendMessage(propertyInfoList);
  console.log(result);

  return result;
};
