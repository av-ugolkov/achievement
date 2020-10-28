import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final bool _isHaveImage = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _isHaveImage
                ? Center(child: Image.asset(''))
                : Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black54,
                      ),
                      child: Icon(
                        Icons.not_interested,
                        color: Colors.grey[300],
                        size: 55,
                      ),
                    ),
                  ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name Achievement Name Achievement Name Achievement Name Achievement',
                          maxLines: 1,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Description',
                          maxLines: 2,
                          softWrap: true,
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                  Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          'Create Date',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.black45),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            '-',
                            style: TextStyle(
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.black45),
                          ),
                        ),
                        Text(
                          'Finish Date',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.black45),
                        ),
                      ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
