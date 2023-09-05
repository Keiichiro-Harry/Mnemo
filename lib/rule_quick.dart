import 'package:flutter/material.dart';

class RuleQuickPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ルールの説明'),
      ),
      body: Align(
        alignment: Alignment.center,
        child:
          Text(
            'こちらはまとめて追加するページです。\n<ルール>\n・改行するとまとめてカードを追加できます。\n・答えでは[]と()と/は特殊記号として扱われます。\n・それ以外の記号は取り除かれることがあります。\n・コロンが1行に0または3つ以上だと追加されません。\n・[]はクイズになり表示されます。\n・()はクイズになりますが表示されません。\n・クイズは漢字に対応していません。\n・答えの中で/を使うと改行ができます。\n・記号を正しく使えていないとエラーが起きます。\n・コメントは任意です。\n<入力例>\n犬:[dog]\nCO2:(にさんかたんそ)二酸化炭素:石灰水で白濁\nbook:名;(ほん)本/動;(よやくする)予約する:名詞と動詞の二つの意味',
            style: TextStyle(
              fontSize: 12, // フォントサイズを指定
              fontWeight: FontWeight.w600, // フォントの太さを指定
              color: Theme.of(context).dividerColor, // テキストの色を指定
            ),
          ),
      ),
    );
  }
}
