/* Java-Kurs – Lektions-Player (eine Lektion innerhalb der Kursseite).
 * JK.mountLesson(root, L, ctx) baut Kopf, „Video“, Aufgabe, Kapitel und Noten der Lektion in root auf.
 * Fortschritt, Quiz-Antworten, Abgaben und die Sperre liegen im gemeinsamen Kurs-Zustand (ctx.state).
 * Ist irgendwo im Kurs eine Aufgabe offen, sind ALLE Videos gesperrt, bis sie abgegeben ist. */
(function () {
  'use strict';
  const JK = window.JK;
  const { $, $$, esc, clamp, fmtTime, md, hl: hlAny, toast, GRADE_WORD } = JK.util;
  const sfx = JK.audio.sfx, audio = JK.audio.state;

  JK.mountLesson = function (root, L, ctx) {
    const S = ctx.state, LS = ctx.ls(L.id);
    const hlJava = (code, lang) => hlAny(code, lang || L.lang);
    const LBL = L.label || 'Lektion ' + L.nr, HASH = L.hash || '#lektion-' + L.nr;
    const { steps, TOTAL, chapterStart, gates, CPS } = JK.buildTimeline(L);
    const nTasks = gates.filter(g => g.task).length, nQuiz = gates.filter(g => g.quiz).length;

    root.innerHTML = `
      <header class="lhead">
        <div class="crumbs"><span>${esc(LBL)} von ${ctx.count}</span></div>
        <h1>${md(L.title)}</h1>
        <p class="lead">${md(L.sub)}</p>
        <div class="meta"><span>⏱ ${Math.round(TOTAL / 60)} Minuten Video</span><span>📝 ${nTasks === 1 ? '1 Aufgabe' : nTasks + ' Aufgaben'} mit Note</span><span>❓ ${nQuiz} Kurz-Checks</span><span>🔇 ohne Ton verständlich</span></div>
      </header>
      <section id="player" class="player" aria-label="Lektions-Video">
        <div id="stage" class="stage" data-lay="title"></div>
        <div class="controls">
          <button id="c-play" class="cbtn play" aria-label="Abspielen">▶</button>
          <div class="seekwrap"><input id="c-seek" type="range" min="0" max="100" value="0" step="1" aria-label="Position im Video"><div id="c-marks" class="marks"></div></div>
          <span id="c-time" class="time">0:00</span>
          <select id="c-speed" aria-label="Tempo"><option value="0.75">0,75×</option><option value="1" selected>1×</option><option value="1.25">1,25×</option><option value="1.5">1,5×</option><option value="2">2×</option></select>
          <button id="c-sfx" class="cbtn" aria-label="Soundeffekte an/aus" title="Soundeffekte">🔊</button>
          <button id="c-music" class="cbtn" aria-label="Hintergrundmusik an/aus" title="Hintergrundmusik">♫</button>
          <button id="c-fs" class="cbtn" aria-label="Vollbild" title="Vollbild">⛶</button>
        </div>
        <div class="nowchap" id="c-chap"></div>
      </section>
      <section id="task" class="task" hidden></section>
      <div class="cols">
        <section class="card"><h2>Kapitel</h2><ol id="chapters" class="chapters"></ol></section>
        <section class="card"><h2>Noten dieser Lektion <span class="avg">Schnitt: <b id="grade-avg">–</b></span></h2><div id="grades" class="grades"></div><p class="small" style="margin:0"><a href="#noten">Alle Noten im Notenbuch →</a></p></section>
      </div>
      <nav class="lnav">${ctx.prevHash ? `<a class="btn ghost" href="${ctx.prevHash}">← ${esc(ctx.prevLabel || 'Lektion ' + (L.nr - 1))}</a>` : '<span></span>'}${ctx.nextHash ? `<a class="btn ghost" href="${ctx.nextHash}">${esc(ctx.nextLabel || 'Lektion ' + (L.nr + 1))} →</a>` : '<span></span>'}</nav>`;

    const stage = $('#stage', root);
    stage.innerHTML = `
      <div class="st-title"><div class="st-kicker"></div><div class="st-h"></div><div class="st-sub"></div></div>
      <div class="st-work">
        <div class="st-editor"><div class="pane-head"><span class="dots"><i></i><i></i><i></i></span><span class="fname">${L.lang === 'js' ? 'main.js' : 'Main.java'}</span></div><div class="ed-scroll"><pre class="ed-code"></pre></div></div>
        <div class="st-side">
          <div class="st-visual"></div>
          <div class="st-console"><div class="pane-head"><span class="con-ico">▍</span>Konsole</div><pre class="con-out"></pre></div>
        </div>
      </div>
      <div class="st-narr"><div class="avatar" aria-hidden="true"></div><p class="say"></p></div>
      <div class="st-gate" hidden></div>
      <div class="st-lock" hidden><div class="lock-card"><div class="lock-ico">🔒</div><h3>Video gesperrt</h3><p class="lock-txt"></p><button class="btn primary" data-act="goto-task">Zur Aufgabe ↓</button></div></div>
      <button class="st-bigplay" aria-label="Abspielen"><span>▶</span></button>`;
    const E = {
      title: $('.st-title', stage), kicker: $('.st-kicker', stage), h: $('.st-h', stage), sub: $('.st-sub', stage),
      code: $('.ed-code', stage), edScroll: $('.ed-scroll', stage), fname: $('.fname', stage),
      visual: $('.st-visual', stage), console: $('.st-console', stage), conOut: $('.con-out', stage),
      narr: $('.st-narr', stage), say: $('.say', stage), gate: $('.st-gate', stage), lock: $('.st-lock', stage), lockTxt: $('.lock-txt', stage), lockBtn: $('[data-act="goto-task"]', stage), bigplay: $('.st-bigplay', stage),
    };
    const ui = {
      play: $('#c-play', root), time: $('#c-time', root), seek: $('#c-seek', root), speed: $('#c-speed', root), sfxBtn: $('#c-sfx', root), musicBtn: $('#c-music', root), fs: $('#c-fs', root),
      marks: $('#c-marks', root), chapters: $('#chapters', root), chapLabel: $('#c-chap', root), curCh: -1,
    };
    const taskEl = $('#task', root);

    const gateDone = st => st.quiz ? !!S.quizzes[st.quiz.id] : !!S.tasks[st.task.id];
    const firstOpenGateTime = () => { const g = gates.find(g => !gateDone(g)); return g ? g.start : TOTAL; };

    // ---------------------------------------------------------------- Darstellung
    const R = { codeKey: '', consKey: '', visIdx: -2, sayStep: -1, sayWords: 0, lay: '', words: [], visEls: [] };
    function renderEditor(st, lt) {
      const d = st.diff;
      let text, cursor = -1;
      if (!d.del.length && !d.ins.length) text = st.codeAfter;
      else {
        const delDur = Math.min(0.5, d.del.length * 0.01);
        const del = lt < delDur ? Math.ceil(d.del.length * (1 - lt / delDur)) : 0;
        const tt = Math.max(0, lt - delDur - 0.2);
        const typeTime = Math.min(d.ins.length / CPS, 3.5 + d.ins.length / 70);
        const n = clamp(Math.floor((tt / typeTime) * d.ins.length), 0, d.ins.length);
        text = d.pre + d.del.slice(0, del) + d.ins.slice(0, n) + d.suf;
        if (n < d.ins.length || del > 0) cursor = d.pre.length + (del > 0 ? del : n);
        if (n > 0 && n < d.ins.length && !/\s/.test(d.ins[n - 1])) sfx.key();
      }
      const hl = st.hl ? (Array.isArray(st.hl[0]) ? st.hl : [st.hl]) : [];
      const key = text + '|' + cursor + '|' + JSON.stringify(hl) + '|' + st.fileName;
      if (key === R.codeKey) return;
      R.codeKey = key;
      E.fname.textContent = st.fileName;
      const html = cursor >= 0 ? hlJava(text.slice(0, cursor)) + '<span class="cur"></span>' + hlJava(text.slice(cursor)) : hlJava(text);
      const inHl = n => hl.some(([a, b]) => n >= a && n <= (b || a));
      E.code.innerHTML = html.split('\n').map((l, i) => `<div class="ln${inHl(i + 1) ? ' hl' : ''}${hl.length && !inHl(i + 1) ? ' dim' : ''}"><span class="no">${i + 1}</span><span class="tx">${l || ' '}</span></div>`).join('');
      const target = $('.cur', E.code) || $('.ln.hl', E.code);
      if (target) { const ln = target.closest('.ln'); const top = ln.offsetTop, h = E.edScroll.clientHeight; if (top < E.edScroll.scrollTop + 20 || top > E.edScroll.scrollTop + h - 40) E.edScroll.scrollTop = Math.max(0, top - h / 2); }
    }
    function renderConsole(st, lt) {
      let lines = st.consBefore, k = 0;
      if (st.run) {
        const start = st.typeDur + 0.2;
        k = lt < start ? 0 : clamp(Math.floor((lt - start) / 0.14) + 1, 0, st.newLines.length);
        lines = st.consBefore.length ? st.consBefore.concat([[]], st.newLines.slice(0, k)) : st.newLines.slice(0, k);
      }
      const key = st.idx + ':' + k + ':' + lines.length;
      if (key === R.consKey) return;
      if (st.run && k > 0 && R.consKey.startsWith(st.idx + ':') && k > Number(R.consKey.split(':')[1])) { k === 1 ? sfx.run() : sfx.line(); }
      R.consKey = key;
      E.conOut.innerHTML = lines.map(segs => '<div class="cl">' + (segs.length ? segs.map(s => `<span class="k-${s.kind}">${esc(s.text)}</span>`).join('') : '&nbsp;') + '</div>').join('');
      E.conOut.scrollTop = E.conOut.scrollHeight;
      E.console.classList.toggle('has', lines.length > 0);
    }
    function visualHTML(v) {
      const at = (i, base, gap) => (base || 0.3) + i * (gap || 0.7);
      switch (v.kind) {
        case 'bullets': return `${v.title ? `<h4>${md(v.title)}</h4>` : ''}<ul class="bul">${v.items.map((it, i) => `<li data-s="${at(i, v.start, v.gap)}">${md(it)}</li>`).join('')}</ul>`;
        case 'big': return `<div class="big" data-s="0.2"><div class="big-main">${md(v.text)}</div>${v.sub ? `<div class="big-sub">${md(v.sub)}</div>` : ''}</div>`;
        case 'boxes': return `${v.title ? `<h4>${md(v.title)}</h4>` : ''}<div class="boxes">${v.vars.map((b, i) => `<div class="box" data-s="${b.s != null ? b.s : at(i, v.start, v.gap)}"><div class="box-type">${esc(b.type)}</div><div class="box-val ${b.cls || ''}">${esc(b.value)}</div><div class="box-name">${esc(b.name)}</div></div>`).join('')}</div>${v.note ? `<p class="vnote" data-s="${v.noteAt || 1.5}">${md(v.note)}</p>` : ''}`;
        case 'table': return `${v.title ? `<h4>${md(v.title)}</h4>` : ''}<table class="vt"><thead><tr>${v.head.map(h => `<th>${md(h)}</th>`).join('')}</tr></thead><tbody>${v.rows.map((r, i) => `<tr data-s="${at(i, v.start, v.gap || 0.5)}">${r.map(c => `<td>${md(String(c))}</td>`).join('')}</tr>`).join('')}</tbody></table>`;
        case 'flow': return `${v.title ? `<h4>${md(v.title)}</h4>` : ''}<div class="flow${v.dir === 'row' ? ' row' : ''}">${v.items.map((it, i) => `${i ? `<div class="arrow" data-s="${at(i, v.start, v.gap) - 0.25}">${v.dir === 'row' ? '→' : '↓'}</div>` : ''}<div class="fstep ${it.cls || ''}" data-s="${at(i, v.start, v.gap)}"><b>${md(it.h)}</b>${it.p ? `<span>${md(it.p)}</span>` : ''}</div>`).join('')}</div>`;
        case 'compare': return `<div class="cmp">${[v.left, v.right].map((c, i) => `<div class="cmp-col ${c.cls || ''}" data-s="${0.3 + i * 1.2}"><div class="cmp-h">${md(c.title)}</div><pre class="cmp-code">${hlJava(c.code, c.lang)}</pre>${c.note ? `<div class="cmp-note">${md(c.note)}</div>` : ''}</div>`).join('')}</div>`;
        case 'code': return `${v.title ? `<h4>${md(v.title)}</h4>` : ''}<pre class="vcode" data-s="0.2">${hlJava(v.code, v.lang)}</pre>${v.note ? `<p class="vnote" data-s="${v.noteAt || 1}">${md(v.note)}</p>` : ''}`;
        case 'html': return v.html;
      }
      return '';
    }
    function renderVisual(st, lt) {
      const vi = st.vis;
      if (vi !== R.visIdx) {
        R.visIdx = vi;
        E.visual.innerHTML = vi >= 0 ? `<div class="vis vis-${steps[vi].visual.kind || 'html'}">${visualHTML(steps[vi].visual)}</div>` : '';
        R.visEls = $$('[data-s]', E.visual).map(el => ({ el, s: parseFloat(el.dataset.s), on: false }));
      }
      if (vi < 0) return;
      const vlt = st.idx === vi ? lt : 1e9;
      for (const x of R.visEls) { const on = vlt >= x.s; if (on !== x.on) { x.on = on; x.el.classList.toggle('in', on); if (on && vlt < 1e8) sfx.pop(); } }
    }
    function renderSay(st, lt) {
      if (R.sayStep !== st.idx) {
        R.sayStep = st.idx;
        if (st.say) {
          const parts = st.say.split(/(`[^`]+`|\*\*[^*]+\*\*)/);
          const words = (txt, b) => txt.split(/(\s+)/).map(w => !w ? '' : /^\s+$/.test(w) ? (w.includes('\n') ? '<br>' : ' ') : `<span class="w">${b ? '<b>' + esc(w) + '</b>' : esc(w)}</span>`).join('');
          let html = '';
          for (const p of parts) {
            if (/^`[^`]+`$/.test(p)) html += `<span class="w"><code>${esc(p.slice(1, -1))}</code></span>`;
            else if (/^\*\*[^*]+\*\*$/.test(p)) html += words(p.slice(2, -2), true);
            else html += words(p, false);
          }
          E.say.innerHTML = html;
          R.words = $$('.w', E.say); R.sayWords = -1;
          E.narr.classList.remove('empty');
          if (st.idx !== 0 && player.playing) sfx.step();
        } else { E.say.innerHTML = ''; R.words = []; E.narr.classList.add('empty'); }
      }
      if (!R.words.length) return;
      const k = clamp(Math.floor(lt * 11) + 1, 0, R.words.length);
      if (k !== R.sayWords) { R.words.forEach((w, i) => w.classList.toggle('on', i < k)); R.sayWords = k; }
    }
    function renderTitle(st) {
      if (R.titleStep === st.idx) return; R.titleStep = st.idx;
      if (!st.t) return;
      E.kicker.textContent = st.t; E.h.innerHTML = md(st.h || ''); E.sub.innerHTML = md(st.sub || '');
      E.title.classList.remove('anim'); void E.title.offsetWidth; E.title.classList.add('anim');
      if (player.playing) sfx.whoosh();
    }
    function stepAt(t) { let lo = 0, hi = steps.length - 1; while (lo < hi) { const mid = (lo + hi + 1) >> 1; if (steps[mid].start <= t) lo = mid; else hi = mid - 1; } return lo; }
    function render(t) {
      const st = steps[stepAt(t)], lt = t - st.start;
      if (st.lay !== R.lay) { stage.dataset.lay = st.lay; R.lay = st.lay; }
      renderTitle(st);
      if (st.lay !== 'title') { renderEditor(st, lt); renderConsole(st, lt); renderVisual(st, lt); }
      renderSay(st, lt);
      stage.classList.toggle('has-visual', st.vis >= 0 && ['split', 'visual', 'all'].includes(st.lay));
      ui.time.textContent = fmtTime(t) + ' / ' + fmtTime(TOTAL);
      ui.seek.value = String(Math.round(t * 10));
      ui.seek.style.setProperty('--p', (t / TOTAL * 100).toFixed(2) + '%');
      if (ui.curCh !== st.ci) { ui.curCh = st.ci; $$('.chap', ui.chapters).forEach((el, k) => el.classList.toggle('now', k === st.ci)); ui.chapLabel.textContent = 'Kapitel ' + (st.ci + 1) + ': ' + L.chapters[st.ci].title; }
    }

    // ---------------------------------------------------------------- Abspielen
    let alive = true;
    const player = {
      t: 0, playing: false, rate: 1, last: 0,
      play() {
        if (S.openTask) { syncLock(); return; }
        if (this.t >= TOTAL - 0.05) this.seek(0);
        const g = gates.find(g => !gateDone(g) && g.start >= this.t - 0.05);
        if (g && Math.abs(this.t - g.start - 0.35) < 0.06) { showGate(g); return; }
        JK.audio.ac(); if (audio.music) JK.audio.setMusic(true);
        this.playing = true; this.last = performance.now(); stage.classList.add('playing', 'started'); ui.play.innerHTML = '❚❚'; ui.play.setAttribute('aria-label', 'Pause');
        hideGate(); requestAnimationFrame(loop);
      },
      pause(save) {
        this.playing = false; stage.classList.remove('playing'); ui.play.innerHTML = '▶'; ui.play.setAttribute('aria-label', 'Abspielen');
        if (save !== false) { LS.t = this.t; ctx.persist(); }
      },
      toggle() { this.playing ? this.pause() : this.play(); },
      seek(t, silent) {
        const limit = firstOpenGateTime();
        if (t > limit) { t = limit; if (!silent) toast(gates.find(g => !gateDone(g)).task ? 'Erst die Aufgabe an dieser Stelle machen – dann geht’s weiter.' : 'Erst die Quizfrage an dieser Stelle beantworten.'); }
        this.t = clamp(t, 0, TOTAL);
        R.codeKey = ''; R.consKey = ''; R.sayStep = -1;
        hideGate();
        render(this.t);
      },
    };
    function loop(now) {
      if (!alive || !player.playing) return;
      const dt = Math.min(0.1, (now - player.last) / 1000) * player.rate; player.last = now;
      let nt = player.t + dt;
      const g = gates.find(g => !gateDone(g) && g.start + 0.35 > player.t && g.start + 0.35 <= nt);
      if (g) { nt = g.start + 0.35; player.t = nt; render(nt); player.pause(); showGate(g); return; }
      if (nt >= TOTAL) { player.t = TOTAL; render(TOTAL); player.pause(); finish(); return; }
      player.t = nt; render(nt);
      if (Math.floor(nt / 15) !== Math.floor((nt - dt) / 15)) { LS.t = nt; ctx.persist(); }
      requestAnimationFrame(loop);
    }

    // ---------------------------------------------------------------- Quiz, Aufgabe, Sperre
    function showGate(g) {
      if (g.task) { openTask(g.task); return; }
      const q = g.quiz;
      E.gate.hidden = false;
      E.gate.innerHTML = `<div class="quiz-card"><div class="quiz-kick">Kurz-Check</div><h3>${md(q.q)}</h3><div class="quiz-opts">${q.options.map((o, i) => `<button class="qopt" data-i="${i}">${md(o)}</button>`).join('')}</div><div class="quiz-fb" hidden></div></div>`;
      sfx.pop();
      $$('.qopt', E.gate).forEach(b => b.addEventListener('click', () => {
        const i = Number(b.dataset.i), ok = i === q.correct;
        $$('.qopt', E.gate).forEach((x, k) => { x.disabled = true; x.classList.toggle('right', k === q.correct); x.classList.toggle('wrong', k === i && !ok); });
        const fb = $('.quiz-fb', E.gate); fb.hidden = false;
        fb.innerHTML = `<p><b>${ok ? 'Richtig!' : 'Nicht ganz.'}</b> ${md(q.explain || '')}</p><button class="btn primary" data-act="quiz-next">Weiter ▶</button>`;
        ok ? sfx.good() : sfx.bad();
        S.quizzes[q.id] = { ok, at: Date.now() }; ctx.persist(); renderGates(); ctx.onChange();
        $('[data-act="quiz-next"]', fb).addEventListener('click', () => { hideGate(); player.play(); });
      }));
    }
    function hideGate() { E.gate.hidden = true; E.gate.innerHTML = ''; }
    const findTask = id => { const s = steps.find(s => s.task && s.task.id === id); return s ? s.task : null; };
    let panel = null;
    function openTask(task) {
      if (S.tasks[task.id]) return;
      S.openTask = { lesson: L.id, id: task.id, title: task.title, nr: L.nr, label: LBL, hash: HASH };
      ctx.persist(); ctx.onChange();
      sfx.lock(); syncLock();
      setTimeout(() => alive && taskEl.scrollIntoView({ behavior: 'smooth', block: 'start' }), 350);
    }
    function mountTaskPanel(task) {
      if (panel && panel.id === task.id) return;
      if (panel) panel.destroy();
      taskEl.hidden = false;
      panel = JK.taskPanel(taskEl, task, ctx, {
        kicker: `Jetzt bist du dran! · ${LBL}, Aufgabe ${task.nr || ''}`,
        note: 'Alle Videos im Kurs sind gesperrt, bis du abgibst. Ob alles stimmt, ist egal – du bekommst auf jeden Fall eine Note und Tipps. Teste vorher mit <b>▶ Ausführen</b>.',
        where: `${LBL}: ${L.title}`,
        continueLabel: 'Video weiter ansehen ▶',
        onSubmitted: () => { S.openTask = null; ctx.persist(); syncLock(); renderGates(); renderGrades(); ctx.onChange(); },
        onContinue: () => { $('#player', root).scrollIntoView({ behavior: 'smooth', block: 'start' }); setTimeout(() => player.play(), 400); },
      });
    }
    function syncLock() {
      const ot = S.openTask, locked = !!ot;
      stage.classList.toggle('locked', locked);
      E.lock.hidden = !locked;
      ui.seek.disabled = locked; ui.play.disabled = locked;
      if (!locked) return;
      if (player.playing) player.pause(false);
      hideGate();
      if (ot.lesson === L.id) {
        const tk = findTask(ot.id);
        E.lockTxt.textContent = `„${tk ? tk.title : ot.title}“ ist offen. Alle Videos im Kurs bleiben gesperrt, bis du deine Lösung abgegeben hast – auch nach dem Neuladen und auf anderen Geräten.`;
        E.lockBtn.textContent = 'Zur Aufgabe ↓';
        E.lockBtn.onclick = () => taskEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
        if (tk) mountTaskPanel(tk);
      } else {
        E.lockTxt.textContent = `In ${ot.label || 'Lektion ' + ot.nr} ist die Aufgabe „${ot.title}“ offen. Solange sind alle Videos gesperrt – so kannst du nicht nachschauen.`;
        E.lockBtn.textContent = `Zur Aufgabe in ${ot.label || 'Lektion ' + ot.nr} →`;
        E.lockBtn.onclick = () => ctx.navigate(ot.hash || '#lektion-' + ot.nr);
      }
    }

    // ---------------------------------------------------------------- Kapitel, Noten, Abschluss
    ui.seek.max = String(Math.round(TOTAL * 10));
    ui.marks.innerHTML = chapterStart.map(s => `<i class="cm" style="left:${(s / TOTAL * 100).toFixed(2)}%"></i>`).join('') + gates.map(g => `<i class="gm ${g.task ? 'task' : 'quiz'}" data-g="${g.task ? g.task.id : g.quiz.id}" style="left:${(g.start / TOTAL * 100).toFixed(2)}%"></i>`).join('');
    ui.chapters.innerHTML = L.chapters.map((c, i) => `<li><button class="chap" data-i="${i}"><span class="cn">${i + 1}</span><span class="ct">${md(c.title)}</span><span class="cd">${fmtTime(chapterStart[i])}</span></button></li>`).join('');
    $$('.chap', ui.chapters).forEach(b => b.addEventListener('click', () => {
      if (S.openTask) { syncLock(); toast('Erst die offene Aufgabe abgeben.'); return; }
      player.pause(false); player.seek(chapterStart[Number(b.dataset.i)]); player.play();
      $('#player', root).scrollIntoView({ behavior: 'smooth', block: 'start' });
    }));
    function renderGates() { $$('.gm', ui.marks).forEach(m => m.classList.toggle('done', m.classList.contains('task') ? !!S.tasks[m.dataset.g] : !!S.quizzes[m.dataset.g])); }
    function renderGrades() {
      const tasks = steps.filter(s => s.task).map(s => s.task);
      $('#grades', root).innerHTML = tasks.map(t => { const r = S.tasks[t.id] && S.tasks[t.id].result; return `<div class="gr${r ? ' g' + r.note : ''}"><div class="gr-num">${r ? r.note : '–'}</div><div><b>${md(t.title)}</b><br><span class="muted">${r ? GRADE_WORD[r.note] + ' · ' + r.punkte + ' Punkte' : 'noch offen'}</span></div></div>`; }).join('');
      const done = tasks.filter(t => S.tasks[t.id]);
      const avg = done.length ? done.reduce((a, t) => a + S.tasks[t.id].result.note, 0) / done.length : null;
      $('#grade-avg', root).textContent = avg ? avg.toFixed(1).replace('.', ',') : '–';
    }
    function finish() {
      LS.done = true; ctx.persist(); ctx.onChange();
      E.gate.hidden = false;
      const tasks = steps.filter(s => s.task).map(s => s.task);
      E.gate.innerHTML = `<div class="quiz-card end"><div class="quiz-kick">${esc(LBL)} geschafft 🎉</div><h3>${md(L.title)}</h3><p>${md(L.outro || 'Super gemacht!')}</p>${tasks.length ? `<p class="muted">Deine Noten: ${tasks.map(t => S.tasks[t.id] ? S.tasks[t.id].result.note : '–').join(' · ')}</p>` : ''}<div class="row">${ctx.endExtra || ''}${ctx.nextHash ? `<a class="btn primary" href="${ctx.nextHash}">${esc(ctx.nextLabel || 'Lektion ' + (L.nr + 1))} →</a>` : ''}<button class="btn ghost" data-act="replay">Nochmal ansehen</button></div></div>`;
      sfx.good();
      $('[data-act="replay"]', E.gate).onclick = () => { hideGate(); player.seek(0); player.play(); };
    }

    // ---------------------------------------------------------------- Steuerung
    ui.play.addEventListener('click', () => player.toggle());
    E.bigplay.addEventListener('click', () => player.play());
    stage.addEventListener('click', e => { if (e.target.closest('button, a, .st-gate, .st-lock')) return; if (!S.openTask) player.toggle(); });
    ui.seek.addEventListener('input', () => { if (S.openTask) return; const was = player.playing; player.pause(false); player.seek(Number(ui.seek.value) / 10); if (was) player.play(); });
    ui.speed.addEventListener('change', () => { player.rate = Number(ui.speed.value); });
    const syncAudioBtns = () => { ui.sfxBtn.classList.toggle('off', !audio.sfx); ui.sfxBtn.setAttribute('aria-pressed', String(audio.sfx)); ui.musicBtn.classList.toggle('off', !audio.music); ui.musicBtn.setAttribute('aria-pressed', String(audio.music)); };
    ui.sfxBtn.addEventListener('click', () => { audio.sfx = !audio.sfx; JK.audio.save(); syncAudioBtns(); if (audio.sfx) { JK.audio.ac(); sfx.pop(); } });
    ui.musicBtn.addEventListener('click', () => { JK.audio.setMusic(!audio.music); syncAudioBtns(); });
    ui.fs.addEventListener('click', () => { const p = $('#player', root); try { if (document.fullscreenElement) document.exitFullscreen(); else p.requestFullscreen().catch(() => toast('Vollbild ist hier nicht verfügbar.')); } catch (e) { toast('Vollbild ist hier nicht verfügbar.'); } });
    const onKey = e => {
      if (e.target.closest('input, textarea, select')) return;
      if (e.key === ' ' || e.key === 'k') { e.preventDefault(); player.toggle(); }
      else if (e.key === 'ArrowRight') { if (!S.openTask) player.seek(player.t + 5); }
      else if (e.key === 'ArrowLeft') { if (!S.openTask) player.seek(player.t - 5); }
    };
    const onVis = () => { if (document.hidden && player.playing) player.pause(); };
    const onResize = () => { R.codeKey = ''; render(player.t); };
    document.addEventListener('keydown', onKey);
    document.addEventListener('visibilitychange', onVis);
    window.addEventListener('resize', onResize);
    syncAudioBtns();

    // ---------------------------------------------------------------- Start
    player.t = Math.min(LS.t || 0, firstOpenGateTime());
    if (player.t > 0.5) stage.classList.add('started');
    render(player.t);
    renderGates(); renderGrades(); syncLock();
    S.last = L.id;

    const api = {
      player, steps, TOTAL, render,
      refresh() { // Zustand kam von einem anderen Gerät
        renderGates(); renderGrades(); syncLock();
        if (!S.openTask && !player.playing) { const lim = firstOpenGateTime(); if (LS.t > player.t + 1) player.seek(Math.min(LS.t, lim), true); }
      },
      destroy() {
        alive = false;
        if (player.playing) player.pause();
        if (panel) panel.destroy();
        document.removeEventListener('keydown', onKey);
        document.removeEventListener('visibilitychange', onVis);
        window.removeEventListener('resize', onResize);
      },
    };
    JK.active = api;
    return api;
  };
})();
