import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initDataTable();
}

initDataTable() {
    if ($.fn.DataTable.isDataTable("#dashboard-table")) {
        $("#dashboard-table").DataTable().destroy();
    }

    let table = $("#dashboard-table").DataTable({
        ajax: {
            url: "/dashboard/data",
            type: "GET",
            dataSrc: "data",
        },
        columns: [
            { data: "id", title: "ID" },
            {
                data: "name",
                title: "Name",
                render: function (data, type, row) {
                    return `<a href="/audition_applications/${row.id}" target="_blank" class="link">${data}</a>`;
                }
            },
            { data: "nationality", title: "Nationality" },
            { data: "gender", title: "Gender" },
            { data: "application_status", title: "Status" },
            // { data: "ethnicity", title: "Ethnicity" },
            {
                data: "votes_count",
                title: "Votes",
                render: function (data, type, row) {
                    if (!Array.isArray(data)) return data;

                    let userNames = { 1: 'MM', 2: 'RS', 3: 'CA' };

                    function getVoteIcon(voteValue) {
                        switch (voteValue) {
                            case 'yes': return { emoji: '✅', text: 'yes' };
                            case 'maybe': return { emoji: '🟡', text: 'maybe' };
                            case 'no': return { emoji: '🔴', text: 'no' };
                            case 'star': return { emoji: '⭐️', text: 'star' };
                            default: return { emoji: '❓', text: 'unknown' };
                        }
                    }

                    let voteHtml = '';

                    data.forEach(vote => {
                        let userName = userNames[vote.user_id] || `User ${vote.user_id}`;
                        let voteData = getVoteIcon(vote.vote_value);

                        // 🔹 Store both emoji & text in a hidden span for better search
                        voteHtml += `<span class="vote-container" style="display: inline-block; margin-right: 10px;">
                                        <strong>${userName}</strong>:
                                        <span class="vote-text">${voteData.text}</span>
                                        ${voteData.emoji}
                                     </span>`;
                    });

                    return voteHtml;
                }
            },
            { data: "result", title: "Result" },
            {
                data: "email",
                title: "Email",
                render: function (data) {
                    return data ? `<a href="mailto:${data}" class="link">Contact</a>` : "";
                }
            },
            {
                data: "video_link",
                title: "URL",
                render: function (data) {
                    return data ? `<a href="${data}" target="_blank" class="link">Video</a>` : "";
                }
            },
            {
                data: "cv",
                title: "CV",
                render: function (data) {
                    return data ? `<a href="${data}" target="_blank" class="link">CV</a>` : "";
                }
            },
            { data: "confirmed_attendance", title: "Confirmed Attendance" }
        ],
        search: { regex: true },
        dom: "lfrtipB",
        buttons: ["copy", "csv", "excel", "pdf", "print"],
        pageLength: 100,
        lengthMenu: [10, 25, 50, 100]
    });

    // 🔹 Improved Universal Search for ALL Relevant Columns
    $.fn.dataTable.ext.search.push(function (settings, data, dataIndex) {
        let searchTerm = $("#dashboard-table_filter input").val().trim().toLowerCase();
        if (!searchTerm) return true; // Show all if search is empty

        // 🔹 Extract all text from the row
        let rowText = $(settings.aoData[dataIndex].nTr).text().toLowerCase();

        // 🔹 Also check hidden vote text
        let voteText = $(settings.aoData[dataIndex].nTr).find(".vote-text").text().toLowerCase();

        return rowText.includes(searchTerm) || voteText.includes(searchTerm);
    });

    // 🔹 Trigger search on keyup
    $("#dashboard-table_filter input").on("keyup", function () {
        table.draw();
    });
}
}
