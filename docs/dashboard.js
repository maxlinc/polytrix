function SDK(sdk, language, editor) {
    this.sdk = sdk;
    this.editor = editor;
    this.language = language;
    this.gitrev = "2c52446133348428bc000dc673b8367b06c10e3c";
    var thissdk = this;
    var suffixMap = {
        'ruby': '.rb',
            'go': '.go',
            'java': '.java',
            'php': '.php',
            'javascript': '.js',
            'python': '.py'
    }
    this.challengeFile = function (challenge) {
        if (this.language === "java") {
            challenge = challenge.charAt(0).toUpperCase() + challenge.slice(1)
        }
        return challenge + suffixMap[this.language];
    }
    this.sourceLinkURL = function () {
        return "https://github.com/maxlinc/drg-tests/blob/master/sdks/" + this.sdk + "/challenges/" + this.challengeFile(challenge);
    };
    this.rawSourceURL = function (challenge) {
        return "https://api.github.com/repos/maxlinc/drg-tests/contents/sdks/" + this.sdk + "/challenges/" + this.challengeFile(challenge);
    };
    this.loadSource = function (challenge) {
        console.log("Loading " + this.rawSourceURL(challenge));
        $.ajax({
            context: this,
            url: this.rawSourceURL(challenge),
            error: function (jqXHR, textStatus, errorThrown) {
                this.editor.setValue("# Not implemented yet");
            },
            success: function (data, status, jqXHR) {
                source = atob(data.content.replace(/\s/g, ""));
                this.editor.setValue(source);
            },
            complete: function (jqXHR, textStatus) {
                this.editor.getSession().setMode("ace/mode/" + this.language);
                $("#editor_nav").html("<a target=\"_blank\" href=\"" + this.sourceLinkURL(challenge) + "\">View on GitHub</a>");
            }
        });
    };
}

function setEditorHeight() {
    var lastLine = $("#editor .ace_gutter-cell:last");
    var neededHeight = lastLine.position().top + lastLine.outerHeight();
    $("#editor-mask").height(neededHeight);
}

function createModal(btn) {
    title = btn.data("modal-title");
    console.log("With title " + title);
    aside = btn.closest(".info-container").find("aside");
    modal = $("#modalPlaceHolder");
    modal.find(".modal-title").text(title);
    console.log("And body " + aside.inner_html);
    modal.find(".modal-body").html(aside.html());
    modal.modal();
}

$(document).ready(function () {
    $('.feature_matrix').on("click", ".modal-button", function () {
        console.log("Creating a modal");
        createModal($(this));
    });

    $('.feature_matrix').stickyTableHeaders();

    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/github");
    editor.getSession().setMode("ace/mode/ruby");

    //$(window).on('resize', setEditorHeight);
    // setEditorHeight();

    var sdks = {
        'fog': new SDK("fog", "ruby", editor),
            'gophercloud': new SDK("gophercloud", "go", editor),
            'jclouds': new SDK("jclouds", "java", editor),
            'php-opencloud': new SDK("php-opencloud", "php", editor),
            'pkgcloud': new SDK("pkgcloud", "javascript", editor),
            'pyrax': new SDK("pyrax", "python", editor)
    };

    for (var sdk in sdks) {
        if (sdks.hasOwnProperty(sdk)) {
            $li = $("<li id=\"" + sdk + "_tab\"><a data-toggle=\"tab\" data-sdk=\"" + sdk + "\" href=\"#\">" + sdk + "</a></li>");
            $("#sdk-nav").append($li);
        }
    }
    $(document).on("click", "a[data-sdk]", function (e) {
        sdk = sdks[$(this).data("sdk")];
        challenge = $(this).data("challenge");
        $("#sdk-nav li a").data("challenge", challenge);
        $("#sdk-nav li").removeClass("active");
        $("#" + sdk.sdk + "_tab").addClass("active");
        console.log("Loading " + sdk);
        sdk.loadSource(challenge);
    });
});
