var Refixative;
(function (Refixative) {
    var Order = (function () {
        function Order(cls) {
            this.classStr = cls;
        }
        Order.Ascending = new Order('asc');
        Order.Descending = new Order('desc');
        Order.prototype.toString = function () {
            return this.classStr;
        };
        return Order;
    })();    
    var Difficulty = (function () {
        function Difficulty(s) {
            this.s = s;
        }
        Difficulty.Basic = new Difficulty('basic');
        Difficulty.Medium = new Difficulty('medium');
        Difficulty.Hard = new Difficulty('hard');
        Difficulty.prototype.toString = function () {
            return this.s;
        };
        return Difficulty;
    })();    
    var SortPreference = (function () {
        function SortPreference(difficulty, target, order) {
            this.difficulty = difficulty;
            this.target = target;
            this.order = order;
        }
        return SortPreference;
    })();    
    var SortMode;
    (function (SortMode) {
        SortMode._map = [];
        SortMode._map[0] = "Default";
        SortMode.Default = 0;
        SortMode._map[1] = "Name";
        SortMode.Name = 1;
        SortMode._map[2] = "Level";
        SortMode.Level = 2;
        SortMode._map[3] = "Score";
        SortMode.Score = 3;
    })(SortMode || (SortMode = {}));
    var PlayerScore = (function () {
        function PlayerScore(score_data, target_table, sort_mode, sort_pref) {
            if (typeof score_data === "undefined") { score_data = []; }
            if (typeof target_table === "undefined") { target_table = null; }
            if (typeof sort_mode === "undefined") { sort_mode = SortMode.Default; }
            if (typeof sort_pref === "undefined") { sort_pref = new SortPreference(Difficulty.Basic, 'lv', Order.Ascending); }
            this.score_data = score_data;
            this.target_table = target_table;
            this.sort_mode = sort_mode;
            this.sort_pref = sort_pref;
            this.refreshSort();
        }
        PlayerScore.prototype.buildRow = function (item) {
            var ps_row = $('<tr />').addClass('player_score');
            var av_row = $('<tr />').addClass('ave_diff');
            ps_row.append($('<td />').attr('rowspan', 2).append($('<a />').attr('href', location.pathname + '/history/' + item['id']).text(item['name'])));
            [
                'basic', 
                'medium', 
                'hard'
            ].forEach(function (diff) {
                ps_row.append($('<td />').attr('rowspan', 2).text(item[diff]['lv'] == 11 ? '10+' : item[diff]['lv']));
                if(item[diff]['score']) {
                    var s = item[diff].score;
                    ps_row.append($('<td />').text($.formatNumber(s.achieve, {
                        format: '0.0'
                    }) + '%'), $('<td />').text(s.miss == 0 ? 'FC' : s.miss).addClass(s.miss == 0 ? 'fullcombo' : (s.miss == 1 ? 'miss1' : (s.miss == 2 ? 'miss2' : ''))), $('<td />').attr('rowspan', 2).text(s.rank));
                    av_row.append($('<td />').text(s.achieve_diff == null ? 'N/A' : ($.formatNumber(s.achieve_diff, {
                        format: '-0.0'
                    }) + '%')).addClass(s.achieve_diff == null ? 'vs_unavailable' : s.achieve_diff == 0.0 ? 'vs_ave_draw' : s.achieve_diff < 0 ? 'vs_ave_lose' : 'vs_ave_win'), $('<td />').text(s.miss_diff == null ? 'N/A' : String($.formatNumber(s.miss_diff, {
                        format: '-0'
                    }))).addClass(s.miss_diff == null ? 'vs_unavailable' : s.miss_diff == 0.0 ? 'vs_ave_draw' : s.miss_diff < 0 ? 'vs_ave_win' : 'vs_ave_lose'));
                } else {
                    ps_row.append($('<td />').attr('rowspan', 2).attr('colspan', 3).addClass('noplay').text('NO PLAY'));
                }
            });
            return {
                score: ps_row,
                vs_ave: av_row
            };
        };
        PlayerScore.prototype.buildTable = function (scores) {
            var _this = this;
            this.target_table.empty();
            $.each(scores, function (index, value) {
                var rows = _this.buildRow(value);
                _this.target_table.append(rows['score']);
                _this.target_table.append(rows['vs_ave']);
            });
        };
        PlayerScore.prototype.reverseOrder = function (order) {
            switch(order) {
                case Order.Ascending: {
                    return Order.Descending;

                }
                case Order.Descending: {
                    return Order.Ascending;

                }
                default: {
                    console.log('[reverseOrder] Invalid Order: ' + order);

                }
            }
        };
        PlayerScore.prototype.sort_by = function (order, selector) {
            if (typeof order === "undefined") { order = Order.Ascending; }
            var rev = (order == Order.Ascending) ? -1 : 1;
            return function (a, b) {
                var x, y;
                if(typeof selector === 'undefined') {
                    x = a;
                    y = b;
                } else {
                    x = selector(a);
                    y = selector(b);
                }
                if(x > y) {
                    return rev * -1;
                }
                if(x < y) {
                    return rev * 1;
                }
                return 0;
            }
        };
        PlayerScore.prototype.scoreSort = function () {
            var _this = this;
            switch(this.sort_mode) {
                case SortMode.Name: {
                    return this.sort_by(this.sort_pref.order, function (x) {
                        return x.name;
                    });

                }
                case SortMode.Level: {
                    return this.sort_by(this.sort_pref.order, function (x) {
                        return x[_this.sort_pref.difficulty.toString()].lv;
                    });

                }
                case SortMode.Score: {
                    return this.sort_by(this.sort_pref.order, function (x) {
                        return x[_this.sort_pref.difficulty.toString()].score[_this.sort_pref.target];
                    });

                }
            }
        };
        PlayerScore.prototype.refreshSort = function () {
            var _this = this;
            var scores = this.score_data.slice(0);
            var sort_func = this.scoreSort();
            if(this.sort_mode != SortMode.Default) {
                if(this.sort_mode == SortMode.Score) {
                    var score_avail = scores.filter(function (val, index) {
                        return !(typeof (val[_this.sort_pref.difficulty.toString()].score) == 'undefined');
                    });
                    var score_not_avail = scores.filter(function (val, index) {
                        return typeof (val[_this.sort_pref.difficulty.toString()].score) == 'undefined';
                    });
                    score_avail.sort(sort_func);
                    scores = score_avail.concat(score_not_avail);
                } else {
                    scores.sort(sort_func);
                }
            }
            this.buildTable(scores);
        };
        PlayerScore.prototype.changeMode = function (target_col, difficulty) {
            switch(this.sort_mode) {
                case SortMode.Default: {
                    switch(target_col) {
                        case 'name': {
                            this.sort_mode = SortMode.Name;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                        case 'lv': {
                            this.sort_mode = SortMode.Level;
                            this.sort_pref.difficulty = difficulty;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                        default: {
                            this.sort_mode = SortMode.Score;
                            this.sort_pref.difficulty = difficulty;
                            this.sort_pref.target = target_col;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                    }
                    break;

                }
                case SortMode.Level: {
                    switch(target_col) {
                        case 'name': {
                            this.sort_mode = SortMode.Name;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                        case 'lv': {
                            if(this.sort_pref.difficulty == difficulty) {
                                this.sort_pref.order = this.reverseOrder(this.sort_pref.order);
                            } else {
                                this.sort_pref.order = Order.Ascending;
                                this.sort_pref.difficulty = difficulty;
                            }
                            break;

                        }
                        default: {
                            this.sort_mode = SortMode.Score;
                            this.sort_pref.difficulty = difficulty;
                            this.sort_pref.target = target_col;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                    }
                    break;

                }
                case SortMode.Name: {
                    switch(target_col) {
                        case 'name': {
                            this.sort_pref.order = this.reverseOrder(this.sort_pref.order);
                            break;

                        }
                        case 'lv': {
                            this.sort_mode = SortMode.Level;
                            this.sort_pref.difficulty = difficulty;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                        default: {
                            this.sort_mode = SortMode.Score;
                            this.sort_pref.difficulty = difficulty;
                            this.sort_pref.target = target_col;
                            this.sort_pref.order = Order.Ascending;

                        }
                    }
                    break;

                }
                case SortMode.Score: {
                    switch(target_col) {
                        case 'name': {
                            this.sort_mode = SortMode.Name;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                        case 'lv': {
                            this.sort_mode = SortMode.Level;
                            this.sort_pref.difficulty = difficulty;
                            this.sort_pref.order = Order.Ascending;
                            break;

                        }
                        default: {
                            if(this.sort_pref.difficulty == difficulty && this.sort_pref.target == target_col) {
                                this.sort_pref.order = this.reverseOrder(this.sort_pref.order);
                            } else {
                                this.sort_pref.difficulty = difficulty;
                                this.sort_pref.target = target_col;
                                this.sort_pref.order = Order.Ascending;
                            }
                            break;

                        }
                    }
                    break;

                }
            }
        };
        return PlayerScore;
    })();    
    var player_score;
    $(document).ready(function () {
        var query = [], hash;
        var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
        for(var i = 0; i < hashes.length; i++) {
            hash = hashes[i].split('=');
            query.push(hash[0]);
            query[hash[0]] = hash[1];
        }
        $.getJSON('/player/' + $("#player_id").val() + '.json' + (query['compare_with'] ? '?compare_with=' + query['compare_with'] : ''), function (json) {
            return player_score = new PlayerScore(json['scores'], $('table#score_data tbody'));
        });
        $('.sort_header').click(function (e) {
            var $target = $(e.target);
            player_score.changeMode($target.data('colname'), $target.data('difficulty'));
            $('#sort_target').removeAttr('id').removeClass('asc desc');
            $target.attr('id', 'sort_target').addClass(player_score.sort_pref.order.toString());
            player_score.refreshSort();
        });
    });
})(Refixative || (Refixative = {}));
